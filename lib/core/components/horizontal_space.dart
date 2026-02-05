import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

import '';

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace({super.key, this.width});
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width?.w);
  }
}
