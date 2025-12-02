import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace({super.key, this.height});
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height?.h);
  }
}
