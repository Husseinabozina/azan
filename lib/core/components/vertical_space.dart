import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace({super.key, this.height});
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height?.h);
  }
}
