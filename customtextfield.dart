import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final FocusNode? focusNode;
  final String? label;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final Color iconColor;
  final Color fillColor;
  final Color hintColor;
  final Color textColor;
  final Color labelColor;
  final Color errorColor;
  final double hintFontSize;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry? prefixIconPadding;
  final EdgeInsetsGeometry? suffixIconPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final double borderRadius;
  final Color borderColor;
  final Color focusedBorderColor;
  final TextDirection? textDirection;
  final bool filled;
  final bool? obscureText;
  final VoidCallback? onSuffixPressed;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Color? cursorColor;
  final double? cursorHeight;
  final double? cursorWidth;
  final bool autocorrect;
  final bool enableSuggestions;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final int? maxLength;
  final bool? enabled;
  final int? maxLines;
  final String? semanticLabel;
  final bool? showCursor;
  final Brightness? keyboardAppearance;
  final AutovalidateMode? autovalidateMode;
  final String? initialValue;
  final Duration? cursorAnimationDuration;
  final Curve? cursorAnimationCurve;
  final bool isMandatory;
  

  const CustomTextField({
    Key? key,
    required this.hint,
    this.focusNode,
    this.label,
    this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.iconColor = Colors.grey,
    this.fillColor = const Color(0xFFF8F9FA),
    this.hintColor = const Color(0xFF9CA3AF),
    this.textColor = const Color(0xFF111827),
    this.labelColor = const Color(0xFF374151),
    this.errorColor = Colors.red,
    this.hintFontSize = 12,
    this.labelFontSize,
    this.labelFontWeight,
    this.contentPadding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    this.prefixIconPadding,
    this.suffixIconPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.borderRadius = 6.0,
    this.borderColor = const Color(0xFFE5E7EB),
    this.focusedBorderColor = Colors.transparent,
    this.textDirection,
    this.filled = true,
    this.obscureText,
    this.onSuffixPressed,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onChanged,
    this.helperText,
    this.helperStyle,
    this.errorText,
    this.errorStyle,
    this.maxLength,
    this.enabled,
    this.maxLines = 1,
    this.semanticLabel,
    this.showCursor,
    this.keyboardAppearance,
    this.autovalidateMode,
    this.initialValue,
    this.cursorAnimationDuration,
    this.cursorAnimationCurve,
    this.isMandatory = false,
  })  : assert(prefix == null || prefixIcon == null,
            'Cannot provide both prefix and prefixIcon'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? label ?? hint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label, mandatory indicator, and error text row
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      color: enabled == false ? theme.disabledColor : labelColor,
                      fontSize: labelFontSize ?? 12,
                      fontWeight: labelFontWeight ?? FontWeight.w500,
                    ),
                  ),
                  if (isMandatory)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: errorColor,
                          fontSize: (labelFontSize ?? 12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (errorText != null)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          errorText!,
                          style: errorStyle ??
                              TextStyle(
                                color: errorColor,
                                fontSize: (labelFontSize ?? 12) - 2,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          // Text field container with consistent height
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: enabled == false ? fillColor.withOpacity(0.5) : fillColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: errorText != null ? errorColor : borderColor,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText ?? isPassword,
              textDirection: textDirection,
              style: TextStyle(
                color: enabled == false ? theme.disabledColor : textColor,
                fontSize: hintFontSize,
                fontWeight: FontWeight.w400,
              ),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              maxLines: maxLines,
              maxLength: maxLength,
              validator: validator,
              cursorColor: cursorColor ?? theme.primaryColor,
              cursorHeight: cursorHeight,
              cursorWidth: cursorWidth ?? 2,
              autocorrect: autocorrect,
              enableSuggestions: enableSuggestions,
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              onChanged: onChanged,
              enabled: enabled ?? true,
              showCursor: showCursor,
              keyboardAppearance: keyboardAppearance,
              autovalidateMode: autovalidateMode,
              initialValue: initialValue,
              cursorRadius: const Radius.circular(2),
              cursorOpacityAnimates: true,
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                hintText: hint,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: hintFontSize,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: prefix ??
                    (prefixIcon != null
                        ? Padding(
                            padding: prefixIconPadding ??
                                const EdgeInsets.only(left: 16, right: 8),
                            child: Icon(
                              prefixIcon,
                              color: enabled == false ? theme.disabledColor : iconColor,
                            ),
                          )
                        : null),
                prefixIconConstraints: prefixIconConstraints ??
                    const BoxConstraints(minWidth: 24, minHeight: 24),
                suffixIcon: suffix ??
                    (isPassword
                        ? IconButton(
                            padding:
                                suffixIconPadding ?? const EdgeInsets.only(right: 8),
                            constraints: suffixIconConstraints,
                            icon: Icon(
                              obscureText ?? false
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: enabled == false ? theme.disabledColor : Colors.grey,
                            ),
                            onPressed: enabled == false ? null : onSuffixPressed,
                          )
                        : null),
                contentPadding: contentPadding,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: focusedBorderColor, width: 2),
                ),
                counterText: maxLength != null ? null : '',
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          
          // Helper text below the text field
          if (helperText != null && errorText == null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                helperText!,
                style: helperStyle ??
                    TextStyle(
                      color: hintColor,
                      fontSize: hintFontSize - 2,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}