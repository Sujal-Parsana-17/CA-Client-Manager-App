import 'dart:developer' as developer;
import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String title, String message, {VoidCallback? onRetry}) {
  developer.log('Error: $title - $message');
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
