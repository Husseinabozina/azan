import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  /// حجم المربع (العرض والارتفاع)
  final double size;

  /// لون البوردر لما يكون مش متعلم
  final Color borderColor;

  /// لون الباكجراوند لما يكون متعلم
  final Color activeColor;

  /// سمك البوردر
  final double borderWidth;

  /// درجة دوران الزوايا
  final double borderRadius;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22, // تقدر تغيره من برة
    this.borderColor = Colors.grey,
    this.activeColor = Colors.blue,
    this.borderWidth = 1.8,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.translucent, // عشان مساحة الضغط تبقى مريحة
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: value ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: value ? activeColor : borderColor,
              width: borderWidth,
            ),
          ),
          child: value
              ? Icon(Icons.check, size: size * 0.6, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
