  import 'package:flutter/material.dart';

  class CustomDropdown<T> extends StatelessWidget {
    final String label;
    final String hint;
    final T? value;
    final List<T> items;
    final ValueChanged<T?>? onChanged;
    final DropdownMenuItem<T> Function(T)? itemBuilder;
    final bool enabled;
    final Color primaryColor;
    final Color fillColor;
    final Color hintColor;
    final Color textColor;
    final Color labelColor;
    final Color errorColor;
    final double hintFontSize;
    final double? labelFontSize;
    final FontWeight? labelFontWeight;
    final EdgeInsetsGeometry contentPadding;
    final double borderRadius;
    final Color borderColor;
    final Color focusedBorderColor;
    final String? errorText;
    final bool isMandatory;
    final String? Function(T?)? validator;

    const CustomDropdown({
      Key? key,
      required this.label,
      required this.hint,
      required this.value,
      required this.items,
       this.onChanged,
       this.itemBuilder,
      this.enabled = true,
      this.primaryColor = const Color(0xff3F51B5),
      this.fillColor = const Color(0xFFF8F9FA),
      this.hintColor = const Color(0xFF9CA3AF),
      this.textColor = const Color(0xFF111827),
      this.labelColor = const Color(0xFF374151),
      this.errorColor = Colors.red,
      this.hintFontSize = 12,
      this.labelFontSize,
      this.labelFontWeight,
      this.contentPadding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
      this.borderRadius = 6.0,
      this.borderColor = const Color(0xFFE5E7EB),
      this.focusedBorderColor =  Colors.transparent,
      this.errorText,
      this.isMandatory = false,
      this.validator,
    }) : super(key: key);

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label and error row
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled ? labelColor : theme.disabledColor,
                fontSize: labelFontSize ?? 14,
                fontWeight: labelFontWeight ?? FontWeight.w500,
                fontFamily: 'AnekLatin-Light',// Add this line
              ),
            ),
            if (isMandatory)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: errorColor,
                    fontSize: (labelFontSize ?? 12),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'AnekLatin-Light', // Add this line
                  ), 
                ),
              ),
            if (errorText != null)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: errorColor,
                      fontSize: (labelFontSize ?? 12) - 2,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'AnekLatin-Light', // Add this line
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      
      // Dropdown field
  DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) => itemBuilder != null 
              ? itemBuilder!(item)
              : DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontFamily: 'AnekLatin-Light',
                    ),
                  ),
                )).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled ? textColor : theme.disabledColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'AnekLatin-Light',
            height: 1.0, // Tight line height
          ),
         isDense: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'AnekLatin-Light',
              height: 1.0,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            constraints: const BoxConstraints.tightFor(height: 40),
            // Static border for all states
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: errorColor, width: 1),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? hintColor : theme.disabledColor,
                size: 20,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
          icon: const SizedBox.shrink(),
          isExpanded: true,
          dropdownColor: Colors.white,
      ),
    ],
  );
}
  }