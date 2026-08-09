# Project Coding Rules

1. Use GetX routing only (`Get.to`, `Get.off`, `Get.offAll`, `Get.back`, etc.). Never use Flutter `Navigator` APIs.
2. Never hardcode user-visible text. Store all UI text in `string_constants.dart` and reference those constants.
3. Add exactly one-line `///` doc comment to every class and method you create or modify.
