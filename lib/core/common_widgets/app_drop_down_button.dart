import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Custom reusable dropdown button widget wrapped with DropdownButton2.
class AppDropDownButton<T> extends StatelessWidget {
  /// The currently selected value.
  final T? value;

  /// List of dropdown options.
  final List<T> options;

  /// Callback triggered when a new option is selected.
  final ValueChanged<T?>? onChanged;

  /// Creates an [AppDropDownButton] instance with required parameters.
  const AppDropDownButton({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
        ),
        child: DropdownButton2<T>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return options.map((T val) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  val.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              );
            }).toList();
          },
          items: options.map((T val) {
            final bool isSelected = val == value;
            return DropdownMenuItem<T>(
              value: val,
              child: Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  val.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(
              left: 16,
              right: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
