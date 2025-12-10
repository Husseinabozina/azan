import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showCircularDialogue(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,

    builder: (ctx) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryTextColor),
      );
    },
  );
}
