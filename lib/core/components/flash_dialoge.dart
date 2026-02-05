import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

enum FlashMessageType { success, error, warning, info }

Color chooseFlashBckColor(FlashMessageType type) {
  Color color;
  switch (type) {
    case FlashMessageType.success:
      color = Colors.green;
      break;
    case FlashMessageType.error:
      color = Colors.red;
      break;
    case FlashMessageType.warning:
      color = Colors.amber;
      break;
    case FlashMessageType.info:
      color = Colors.grey.shade700;
      break;
  }

  return color;
}

void showFlashMessage({
  required String message,
  required FlashMessageType type,
  required BuildContext context,
  Color? textColor,
  FlashPosition position = FlashPosition.bottom,
  Duration? duration,
}) {
  showFlash(
    context: context,
    duration: duration ?? const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash(
        controller: controller,
        position: FlashPosition.bottom,
        child: FlashBar(
          controller: controller,
          backgroundColor: chooseFlashBckColor(type),
          elevation: 6,
          margin: EdgeInsets.symmetric(horizontal: 55.w, vertical: 70.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          behavior: FlashBehavior.fixed,
          position: position,
          showProgressIndicator: false,
          shadowColor: Colors.black38,
          primaryAction: null,
          useSafeArea: false,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: textColor ?? Colors.white),
          ),
        ),
      );
    },
  );
}
