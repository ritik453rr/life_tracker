import 'package:flutter/material.dart';

/// Provides shorthand extensions to create SizedBox widgets for width and height spacing.
extension SizedBoxExt on num {
  SizedBox get w => SizedBox(width: toDouble());
  SizedBox get h => SizedBox(height: toDouble());
}
