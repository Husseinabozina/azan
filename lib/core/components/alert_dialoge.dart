import 'package:flutter/material.dart';

import '../utils/dialoge_helper.dart';

void showCircularDialogue(BuildContext context) {
  showAppDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return UniversalDialogShell(
        customMaxWidth: 160,
        customMaxHeight: 160,
        child: Center(
          child: CircularProgressIndicator(
            color: DialogPalette.primaryButtonBackground,
          ),
        ),
      );
    },
  );
}
