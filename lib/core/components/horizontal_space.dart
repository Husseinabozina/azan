import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace({
    super.key,
    this.width,
  });
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.w,
    );
  }
}
