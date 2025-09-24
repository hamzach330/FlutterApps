#!/usr/bin/env python3
import os
import re
import json
import sys
import datetime
import unicodedata
from collections import defaultdict, Counter

# Configuration
EXCLUDED_DIRS = {
    'build', '.dart_tool', '.git', os.path.join('ios', 'Pods'),
    os.path.join('android', '.gradle'), os.path.join('android', 'build')
}
EXCLUDED_GLOBS_SUFFIX = (
    os.path.sep + 'generated' + os.path.sep,
)

REPORT_PATH = os.path.join(os.getcwd(), 'i18n_audit.md')

# Regex helpers
SINGLE_OR_DOUBLE = r"(?:'[^'\\\n]*(?:\\.[^'\\\n]*)*'|\"[^\"\\\n]*(?:\\.[^\"\\\n]*)*\")"
TRIPLE_QUOTED = r"(?:'''[\s\S]*?'''|\"\"\"[\s\S]*?\"\"\")"
RAW_PREFIX = r"[rR]?"
STRING_LITERAL = rf"{RAW_PREFIX}(?:{TRIPLE_QUOTED}|{SINGLE_OR_DOUBLE})"

# Basic literal extraction (strip quotes and handle raw prefixes)
def unquote_literal(lit: str) -> str:
    s = lit
    if s.startswith(('r', 'R')) and len(s) > 1:
        s = s[1:]
    if (s.startswith("'''") and s.endswith("'''") and len(s) >= 6) or (s.startswith('"""') and s.endswith('"""') and len(s) >= 6):
        return s[3:-3]
    if (s.startswith("'") and s.endswith("'")) or (s.startswith('"') and s.endswith('"')):
        # Unescape common sequences, preserving \n etc. as-is for display
        content = s[1:-1]
        try:
            # decode python-style escapes but keep backslashes for readability
            content = bytes(content, 'utf-8').decode('unicode_escape')
        except Exception:
            pass
        return content
    return s

def is_probably_non_ui(text: str) -> bool:
    t = text.strip()
    if t == '':
        return True
    # numbers only
    if re.fullmatch(r"\d+(?:[.,]\d+)?", t):
        return True
    # URLs or paths
    if re.match(r"^[a-zA-Z]+://", t) or '/' in t or t.startswith('www.'):
        return True
    # UUID-like
    if re.fullmatch(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", t):
        return True
    return False

def strip_diacritics(s: str) -> str:
    # Special German chars
    s = s.replace('ß', 'ss').replace('ẞ', 'ss')
    # decompose and remove diacritics
    nfkd = unicodedata.normalize('NFKD', s)
    return ''.join(c for c in nfkd if not unicodedata.combining(c))

def normalize_for_key(text: str) -> str:
    # Convert placeholders like $name or ${var} -> {name}
    def repl_placeholder(m):
        name = m.group(1) or m.group(2)
        return '{' + name + '}'

    text = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)|\$\{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\}", repl_placeholder, text)
    # Lowercase, trim, collapse whitespace
    text = strip_diacritics(text).lower().strip()
    text = re.sub(r"\s+", " ", text)
    # Remove punctuation except spaces and braces inside placeholders
    # Keep braces and underscores candidates
    text = re.sub(r"[^a-z0-9 {}]", "", text)
    # Convert spaces to underscores
    text = text.replace(' ', '_')
    # Collapse multiple underscores
    text = re.sub(r"_+", "_", text)
    return text

def glob_excluded(path: str) -> bool:
    for suf in EXCLUDED_GLOBS_SUFFIX:
        if suf in path:
            return True
    if path.endswith('.g.dart'):
        return True
    return False

def should_exclude_dir(dirpath: str) -> bool:
    # Exclude if any path component matches excluded set
    parts = dirpath.split(os.path.sep)
    for i in range(1, len(parts)+1):
        prefix = os.path.sep.join(parts[:i])
        for ex in EXCLUDED_DIRS:
            # exact component match
            if parts[i-1] == ex or prefix.endswith(ex):
                return True
    return False

# Patterns per context
CTX_PATTERNS = [
    (re.compile(rf"\bText\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'Text'),
    (re.compile(rf"\btitle\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'title: Text'),
    (re.compile(rf"\blabel\s*:\s*(?:Text\(\s*)?({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'label'),
    (re.compile(rf"\btooltip\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'tooltip'),
    (re.compile(rf"\bsemantics?Label\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'semanticLabel'),
    (re.compile(rf"\bhintText\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'hintText'),
    (re.compile(rf"\bhelperText\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'helperText'),
    (re.compile(rf"\berrorText\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'errorText'),
    (re.compile(rf"\bbuttonText\s*:\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'buttonText'),
    (re.compile(rf"\bcontent\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'content: Text'),
    (re.compile(rf"\bAppBar\(\s*title\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'AppBar title'),
    (re.compile(rf"\b(ElevatedButton|TextButton|OutlinedButton)\b[\s\S]*?child\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'Button child Text'),
    (re.compile(rf"\bPopupMenuItem\b[\s\S]*?child\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'PopupMenuItem Text'),
    (re.compile(rf"\bListTile\b[\s\S]*?title\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'ListTile title'),
    (re.compile(rf"\bListTile\b[\s\S]*?subtitle\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'ListTile subtitle'),
    (re.compile(rf"\bSnackBar\b[\s\S]*?content\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'SnackBar content'),
    (re.compile(rf"\bAlertDialog\b[\s\S]*?(title|content)\s*:\s*Text\(\s*({STRING_LITERAL})(?:\s*\.\s*i18n\b)?"), 'AlertDialog'),
]

# Generic .i18n occurrences anywhere
I18N_CHAIN_RE = re.compile(rf"({STRING_LITERAL})\s*\.\s*i18n\b")

def find_matches_in_file(path: str):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return []

    occurrences = []

    # Specific context patterns
    for pat, ctx in CTX_PATTERNS:
        for m in pat.finditer(content):
            # The literal group might be group 1 or 2 depending on pattern
            lit = m.group(1)
            if not lit:
                lit = m.group(m.lastindex or 1)
            start = m.start(1)
            # Determine if i18n present by checking the matched text for .i18n after literal
            after = content[m.end(1):m.end(1)+20]
            has_i18n = bool(re.match(r"\s*\.\s*i18n\b", after))
            value = unquote_literal(lit)
            if is_probably_non_ui(value):
                continue
            line = content.count('\n', 0, start) + 1
            occurrences.append({
                'path': path,
                'line': line,
                'literal': lit,
                'text': value,
                'context': ctx,
                'has_i18n': has_i18n,
            })

    # Also include any generic '...'.i18n not matched above
    for m in I18N_CHAIN_RE.finditer(content):
        lit = m.group(1)
        start = m.start(1)
        value = unquote_literal(lit)
        if is_probably_non_ui(value):
            continue
        line = content.count('\n', 0, start) + 1
        # Avoid duplicates: if same (path,line,text) already captured, skip
        if any(o['path']==path and o['line']==line and o['text']==value for o in occurrences):
            continue
        occurrences.append({
            'path': path,
            'line': line,
            'literal': lit,
            'text': value,
            'context': 'i18n literal',
            'has_i18n': True,
        })

    # Deduplicate exact duplicates
    unique = []
    seen = set()
    for o in occurrences:
        key = (o['path'], o['line'], o['text'], o['context'], o['has_i18n'])
        if key not in seen:
            seen.add(key)
            unique.append(o)
    return unique

def find_dart_files(root: str):
    for dirpath, dirnames, filenames in os.walk(root):
        # Modify dirnames in-place to skip excluded dirs
        dirnames[:] = [d for d in dirnames if not should_exclude_dir(os.path.join(dirpath, d))]
        for fn in filenames:
            if not fn.endswith('.dart'):
                continue
            full = os.path.join(dirpath, fn)
            if glob_excluded(full):
                continue
            yield full

def collect_locale_files(root: str):
    candidates = []
    for dirpath, dirnames, filenames in os.walk(root):
        # Skip excluded
        dirnames[:] = [d for d in dirnames if not should_exclude_dir(os.path.join(dirpath, d))]
        for fn in filenames:
            low = fn.lower()
            if low.endswith('.json') or low.endswith('.arb'):
                rel = os.path.relpath(os.path.join(dirpath, fn), root)
                if ('assets' + os.path.sep + 'locale' + os.path.sep) in rel or \
                   ('assets' + os.path.sep + 'locales' + os.path.sep) in rel or \
                   (os.path.sep + 'lib' + os.path.sep + 'l10n' + os.path.sep) in (os.path.sep + rel) or \
                   (os.path.sep + 'lib' + os.path.sep + 'i18n' + os.path.sep) in (os.path.sep + rel):
                    candidates.append(os.path.join(dirpath, fn))
    return candidates

def detect_locale_from_filename(filename: str) -> str:
    base = os.path.basename(filename)
    m = re.search(r"[_\.-]([a-z]{2}(?:_[A-Z]{2})?)\.(?:json|arb)$", base)
    if m:
        return m.group(1)
    # fallback
    if base.endswith('.arb') or base.endswith('.json'):
        return os.path.splitext(base)[0]
    return base

def load_locales(root: str):
    locales = {}  # locale -> {key: value}
    files = collect_locale_files(root)
    for path in files:
        try:
            with open(path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except Exception:
            continue
        # ARB/JSON may include meta keys starting with @
        entries = {k: v for k, v in data.items() if not k.startswith('@') and isinstance(v, (str, int, float, bool))}
        locale = detect_locale_from_filename(path)
        locales.setdefault(locale, {}).update(entries)
    return locales

def get_context_snippet(path: str, target_line: int, radius: int = 2) -> str:
    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception:
        return ''
    start = max(1, target_line - radius)
    end = min(len(lines), target_line + radius)
    snippet = ''.join(lines[start-1:end])
    return snippet

def main():
    root = os.getcwd()

    # Collect occurrences
    all_occ = []
    for f in find_dart_files(root):
        all_occ.extend(find_matches_in_file(f))

    # Group by normalized key
    groups = {}
    order = []
    for o in all_occ:
        norm = normalize_for_key(o['text'])
        if norm not in groups:
            groups[norm] = {
                'text_variants': Counter(),
                'occurrences': [],
                'has_i18n_any': False,
                'contexts': Counter(),
            }
            order.append(norm)
        groups[norm]['text_variants'][o['text']] += 1
        groups[norm]['occurrences'].append(o)
        if o['has_i18n']:
            groups[norm]['has_i18n_any'] = True
        groups[norm]['contexts'][o['context']] += 1

    # Load locales
    locales = load_locales(root)
    locale_keys = {loc: set(entries.keys()) for loc, entries in locales.items()}

    # Prepare report
    ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Summary counts
    total_strings = len(order)
    not_localized = 0
    i18n_missing = 0
    i18n_present = 0

    rows = []

    for norm in order:
        data = groups[norm]
        # Choose representative literal (most common variant)
        rep_text, _ = data['text_variants'].most_common(1)[0]
        proposed_key = norm

        # Determine presence in locales: try literal and proposed key
        matched_locales = []
        matched_keys = set()
        for loc, keys in locale_keys.items():
            if rep_text in keys:
                matched_locales.append(loc)
                matched_keys.add(rep_text)
            elif proposed_key in keys:
                matched_locales.append(loc)
                matched_keys.add(proposed_key)

        if not data['has_i18n_any']:
            status = 'not_localized'
            not_localized += 1
        else:
            if matched_locales:
                status = 'i18n_present'
                i18n_present += 1
            else:
                status = 'i18n_missing_in_locales'
                i18n_missing += 1

        files_lines = [f"{o['path']}:{o['line']}" for o in sorted(data['occurrences'], key=lambda x: (x['path'], x['line']))]
        ctx_list = sorted(data['contexts'].keys())
        rows.append({
            'rep_text': rep_text,
            'proposed_key': proposed_key,
            'status': status,
            'locales_present': sorted(set(matched_locales)),
            'files_lines': files_lines,
            'contexts': ctx_list,
            'norm': norm,
            'matched_keys': sorted(matched_keys),
        })

    # Write markdown
    with open(REPORT_PATH, 'w', encoding='utf-8') as out:
        out.write(f"# i18n Audit — {ts}\n\n")
        out.write("**Summary**\n\n")
        out.write(f"- Total strings found: {total_strings}\n")
        out.write(f"- Not localized (no .i18n): {not_localized}\n")
        out.write(f"- Localized (.i18n) but missing in locale files: {i18n_missing}\n")
        out.write(f"- Localized (.i18n) and present in locale files: {i18n_present}\n\n")

        # Table header
        out.write("**Per-String Results**\n\n")
        out.write("| String | Proposed Key | Status | Locales Present | Files/Lines | Widget/Context |\n")
        out.write("|---|---|---|---|---|---|\n")
        for r in rows:
            s = r['rep_text'].replace('|', '\\|').replace('\n', ' ')
            locales_present = ','.join(r['locales_present']) if r['locales_present'] else '—'
            files = '<br>'.join(r['files_lines'])
            ctx = ', '.join(r['contexts'])
            anchor = r['proposed_key'] or r['norm']
            out.write(f"| [{s}](#{anchor}) | {r['proposed_key']} | {r['status']} | {locales_present} | {files} | {ctx} |\n")

        out.write("\n**Details**\n\n")
        for r in rows:
            anchor = r['proposed_key'] or r['norm']
            out.write(f"### {r['rep_text']} <a id=\"{anchor}\"></a>\n\n")
            out.write(f"- Proposed Key: `{r['proposed_key']}`\n")
            out.write(f"- Status: {r['status']}\n")
            locales_present = ','.join(r['locales_present']) if r['locales_present'] else '—'
            out.write(f"- Locales Present: {locales_present}\n")
            if len(groups[r['norm']]['text_variants']) > 1:
                variants = ', '.join(sorted(groups[r['norm']]['text_variants'].keys()))
                out.write(f"- Variants seen: {variants}\n")
            out.write("\n")

            # Code references
            for o in sorted(groups[r['norm']]['occurrences'], key=lambda x: (x['path'], x['line'])):
                out.write(f"{o['path']}:{o['line']} — {o['context']} — {'with .i18n' if o['has_i18n'] else 'no .i18n'}\n\n")
                snippet = get_context_snippet(o['path'], o['line'], radius=2)
                out.write("```dart\n")
                out.write(snippet)
                out.write("```\n\n")

            # Locale entries details
            if r['status'] == 'i18n_present' and locales:
                out.write("Translations found:\n\n")
                keys_to_show = r['matched_keys'] if r['matched_keys'] else [r['proposed_key']]
                for k in keys_to_show:
                    out.write(f"- Key: `{k}`\n")
                    for loc, entries in sorted(locales.items()):
                        if k in entries:
                            out.write(f"  - {loc}: {entries[k]}\n")
                    out.write("\n")
            elif r['status'] != 'i18n_present':
                out.write("Action: Add to locales under proposed key.\n\n")

    print(f"Wrote {REPORT_PATH}")

if __name__ == '__main__':
    main()
