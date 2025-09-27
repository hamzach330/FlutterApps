# Tools

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](https://becker-antriebe.com)

## Overview

The Tools directory contains utility scripts and tools for development, maintenance, and quality assurance of the Becker applications ecosystem. These tools provide automation, analysis, and support functions for the development workflow.

## Available Tools

### 🔍 **i18n_audit.py**
- **Purpose**: Internationalization audit and analysis tool
- **Functionality**: Analyzes translation completeness and consistency
- **Usage**: Python script for i18n quality assurance
- **Output**: Detailed audit reports and recommendations

## Tools Description

### i18n_audit.py

A comprehensive internationalization audit tool that analyzes the translation state across all Becker applications and modules.

#### Features
- **Translation Completeness**: Checks for missing translations
- **Consistency Analysis**: Validates translation consistency across languages
- **Quality Assessment**: Evaluates translation quality and accuracy
- **Coverage Reporting**: Provides detailed coverage reports
- **Recommendation Engine**: Suggests improvements and fixes

#### Usage
```bash
# Run i18n audit
python tools/i18n_audit.py

# Audit specific module
python tools/i18n_audit.py --module control_tool

# Generate detailed report
python tools/i18n_audit.py --output report.html --format html

# Check specific languages
python tools/i18n_audit.py --languages de,en,fr
```

#### Command Line Options
```bash
Options:
  --module MODULE       Specific module to audit
  --languages LANGS     Comma-separated list of languages
  --output FILE         Output file path
  --format FORMAT       Output format (json, html, csv)
  --verbose             Enable verbose output
  --help                Show help information
```

#### Output Formats
- **JSON**: Machine-readable audit results
- **HTML**: Human-readable report with charts
- **CSV**: Spreadsheet-compatible format
- **Console**: Terminal output with color coding

## Development Workflow Integration

### Pre-commit Hooks
```bash
#!/bin/bash
# Pre-commit hook for i18n validation
python tools/i18n_audit.py --fail-on-errors
```

### CI/CD Integration
```yaml
# GitHub Actions example
name: I18n Audit
on: [push, pull_request]

jobs:
  i18n-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r tools/requirements.txt
      - name: Run i18n audit
        run: python tools/i18n_audit.py --output audit-report.html
      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: i18n-audit-report
          path: audit-report.html
```

### Makefile Integration
```makefile
# I18n audit
.PHONY: i18n-audit
i18n-audit:
	python tools/i18n_audit.py --output i18n-report.html

# I18n validation
.PHONY: i18n-validate
i18n-validate:
	python tools/i18n_audit.py --fail-on-errors

# I18n report
.PHONY: i18n-report
i18n-report: i18n-audit
	@echo "I18n audit report generated: i18n-report.html"
```

## Configuration

### Configuration File
Create a `tools_config.yaml` file in the project root:
```yaml
# Tools configuration
i18n_audit:
  # Audit settings
  check_completeness: true
  check_consistency: true
  check_quality: true
  
  # Language settings
  default_languages:
    - "de"
    - "en"
    - "fr"
    - "es"
  
  # Output settings
  output_format: "html"
  include_charts: true
  color_output: true
  
  # Quality thresholds
  min_completeness: 0.95
  min_consistency: 0.90
  min_quality: 0.85
  
  # File patterns
  translation_files:
    - "**/*.po"
    - "**/*.json"
    - "**/strings.pot"
  
  exclude_patterns:
    - "**/test/**"
    - "**/generated/**"
```

### Environment Variables
```bash
# I18n audit configuration
export I18N_AUDIT_LANGUAGES="de,en,fr,es"
export I18N_AUDIT_OUTPUT_FORMAT="html"
export I18N_AUDIT_MIN_COMPLETENESS="0.95"
export I18N_AUDIT_VERBOSE="true"
```

## Requirements

### Python Dependencies
```txt
# requirements.txt
click>=8.0.0
pyyaml>=6.0
jinja2>=3.0.0
colorama>=0.4.4
tabulate>=0.9.0
```

### System Requirements
- **Python**: 3.8 or higher
- **Operating System**: Windows, macOS, Linux
- **Memory**: Minimum 512MB RAM
- **Disk Space**: 100MB for tools and dependencies

## Troubleshooting

### Common Issues

#### Python Environment
- Ensure Python 3.8+ is installed
- Install required dependencies
- Check Python path configuration
- Verify virtual environment activation

#### Permission Issues
- Check file read/write permissions
- Ensure proper directory access
- Verify tool execution permissions
- Check antivirus software interference

#### Configuration Issues
- Validate configuration file syntax
- Check environment variable settings
- Verify file path configurations
- Ensure proper encoding (UTF-8)

### Debug Mode
```bash
# Enable debug output
python tools/i18n_audit.py --verbose --debug

# Test configuration
python tools/i18n_audit.py --test-config

# Validate setup
python tools/i18n_audit.py --validate-setup
```

## Contributing

### Development Guidelines
1. Follow Python PEP 8 style guidelines
2. Add comprehensive error handling
3. Include unit tests for new tools
4. Update documentation
5. Ensure cross-platform compatibility

### Code Style
- Use `black` for code formatting
- Follow existing naming conventions
- Add comprehensive docstrings
- Use type hints where appropriate

### Testing Requirements
- Unit tests for all tool functions
- Integration tests with sample data
- Error handling tests
- Cross-platform compatibility tests

## License

This project is proprietary software developed by Becker-Antriebe GmbH. All rights reserved.

## Support

For technical support and questions:
- **Documentation**: [Internal Wiki](https://wiki.becker-antriebe.com)
- **Issues**: [Internal Issue Tracker](https://gitlab.becker-antriebe.com)
- **Email**: support@becker-antriebe.com

---

**Note**: These tools are designed for development and maintenance purposes. Always test tools in a development environment before using them in production workflows.
