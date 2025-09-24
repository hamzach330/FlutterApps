part of ui_common;

enum UICTextInputLabelSide {
  top, left, bottom
}

class UICTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final bool autofocus;
  final List<String> autofillHints;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final bool readonly;
  final TextAlign textAlign;
  final UICTextInputLabelSide labelSide;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool invalid;
  final String? fontFamily;
  final bool isDense;
  final Function()? onClear;
  final FocusNode? focusNode;

  const UICTextInput({
    required this.controller,
    this.label,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.autofillHints = const [],
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.hintText,
    this.readonly = false,
    this.textAlign = TextAlign.start,
    this.labelSide = UICTextInputLabelSide.top,
    this.maxLength,
    this.inputFormatters,
    this.invalid = false,
    this.obscureText = false,
    this.isDense = true,
    this.onClear,
    this.fontFamily,
    this.focusNode,
    super.key
  });

  @override
  State<UICTextInput> createState() => _UICTextInputState();
}

class _UICTextInputState extends State<UICTextInput> {
  bool obscureText = false;

  @override
  initState() {
    super.initState();
    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            focusNode: widget.focusNode,
            onTapOutside: (event) {
              widget.focusNode?.unfocus();
            },
            // padding: EdgeInsets.zero,
            maxLength: widget.maxLength,
            textAlign: widget.textAlign,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontFamily: widget.fontFamily,
              fontSize: 14
            ),
            readOnly: widget.readonly,
            obscureText: obscureText,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            autofillHints: widget.autofillHints,
            controller: widget.controller,
            // placeholder: widget.hintText,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
    
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.onSecondaryContainer, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.onSecondaryContainer, width: 1.0),
              ),
              labelText: widget.label,
              hintText: widget.hintText,
              counterText: "",
              isDense: widget.isDense,
              // contentPadding: EdgeInsets.all(theme.defaultWhiteSpace),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              maintainHintHeight: false,
              suffixIcon: widget.onClear != null ? IconButton(
                onPressed: widget.onClear,
                icon: Icon(Icons.clear),
              ) : null,
              
            ),
          ),
        ),
    
        if(widget.obscureText) Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: GestureDetector(
            child: Icon(!obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: .3)
            ),
            onTap: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        )
    
      ],
    );
  }
}

class UICTextFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final bool autofocus;
  final List<String> autofillHints;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final bool readonly;
  final TextAlign textAlign;
  final UICTextInputLabelSide labelSide;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool invalid;
  final String? fontFamily;
  final bool isDense;
  final Function()? onClear;
  final String? initialValue;
  final Function(String?)? onSaved;
  final Function()? onObscure;


  const UICTextFormField({
    this.initialValue,
    this.label,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.autofillHints = const [],
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.hintText,
    this.readonly = false,
    this.textAlign = TextAlign.start,
    this.labelSide = UICTextInputLabelSide.top,
    this.maxLength,
    this.inputFormatters,
    this.invalid = false,
    this.obscureText = false,
    this.isDense = true,
    this.onClear,
    this.fontFamily,
    this.onSaved,
    this.onObscure,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initialValue,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
        fontFamily: fontFamily,
        fontSize: 14
      ),
      readOnly: readonly,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator: validator,
      inputFormatters: inputFormatters,
      onSaved: onSaved,

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.onSecondaryContainer, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.onSecondaryContainer, width: 1.0),
        ),

        suffixIcon: onObscure == null ? null : IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            onObscure?.call();
          },
        ),

        labelText: label,
        hintText: hintText,
        counterText: "",
        isDense: isDense,
      )
    );
  }
}
        // contentPadding: EdgeInsets