import 'package:flutter/material.dart';

int accelerationSampleRateMS = 33;

ButtonStyle textButtonStyle(BuildContext context) {
  return TextButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onSecondary,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    padding: const EdgeInsets.all(16.0),
    textStyle: Theme.of(context).textTheme.headlineSmall,
  );
}