import 'package:flutter/material.dart';

/// Provides shorthand extensions to create SizedBox widgets for width and height spacing.
extension SizedBoxExt on num {
  /// Returns a [SizedBox] with width equal to this number.
  SizedBox get w => SizedBox(width: toDouble());

  /// Returns a [SizedBox] with height equal to this number.
  SizedBox get h => SizedBox(height: toDouble());
}
