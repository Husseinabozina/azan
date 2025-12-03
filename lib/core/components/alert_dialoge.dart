import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showCircularDialogue(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,

    builder: (ctx) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryTextColor),
      );
    },
  );
}
