import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;
  final Function(String)? onChanged;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(AppConstants.otpLength, (index) => FocusNode());
    _controllers = List.generate(
      AppConstants.otpLength,
      (index) => TextEditingController(),
    );

    // Listen to main controller changes
    widget.controller.addListener(_onMainControllerChanged);
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    widget.controller.removeListener(_onMainControllerChanged);
    super.dispose();
  }

  void _onMainControllerChanged() {
    final text = widget.controller.text;
    for (int i = 0; i < AppConstants.otpLength; i++) {
      _controllers[i].text = i < text.length ? text[i] : '';
    }
  }

  void _onChanged(String value, int index) {
    // Update main controller
    final currentText = widget.controller.text;
    final newText = currentText.padRight(AppConstants.otpLength, ' ');
    final chars = newText.split('');
    chars[index] = value;
    widget.controller.text = chars.join('').trim();

    // Move focus
    if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Call callbacks
    widget.onChanged?.call(widget.controller.text);

    if (widget.controller.text.length == AppConstants.otpLength) {
      widget.onCompleted(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          AppConstants.otpLength,
          (index) => SizedBox(
            width: 55,
            height: 60,
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: AppColors.surface,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => _onChanged(value, index),
              onTap: () {
                _controllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: _controllers[index].text.length),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
