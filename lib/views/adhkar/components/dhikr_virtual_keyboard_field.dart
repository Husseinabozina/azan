import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:flutter/material.dart';

class DhikrVirtualKeyboardField extends StatelessWidget {
  const DhikrVirtualKeyboardField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    required this.contentPadding,
    this.maxLines = 3,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final EdgeInsetsGeometry contentPadding;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return VirtualTextField(
      controller: controller,
      hintText: hintText,
      validator: validator,
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
      contentPadding: contentPadding,
      borderRadius: sizing.borderRadius,
      minFieldHeight: sizing.bodyFontSize * maxLines * 1.45,
      theme: const VirtualKeyboardFieldTheme(
        fillColor: Colors.white,
        borderColor: Color(0xFFB0B7C1),
        activeBorderColor: Color(0xFFF4C66A),
        errorBorderColor: Colors.red,
        textColor: Colors.black87,
        hintColor: Color(0xFF6B7280),
        labelColor: Color(0xFF6B7280),
        keyboardTextColor: Colors.black87,
        keyboardBackgroundColor: Colors.white,
        keyboardBorderColor: Color(0x66F4C66A),
        keyboardShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: Colors.black87,
        fontSize: sizing.bodyFontSize,
        height: 1.45,
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade700,
        fontSize: sizing.bodyFontSize * 0.82,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
