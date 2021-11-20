import 'package:flutter/material.dart';

void showNotify(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
    ),
  );
}

Future<void> showWarningMessage({
  required BuildContext context,
  required String message,
  required Function() onAccept,
}) async {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text('Are you sure?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            onAccept();
            Navigator.pop(context);
          },
          child: const Text('ACCEPT'),
        ),
      ],
    ),
  );
}
