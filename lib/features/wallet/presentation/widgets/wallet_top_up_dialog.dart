import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletTopUpDialog extends StatefulWidget {
  final Function(int amount) onTopUp; // Amount in Iraqi Dinars (IQD)

  const WalletTopUpDialog({super.key, required this.onTopUp});

  @override
  State<WalletTopUpDialog> createState() => _WalletTopUpDialogState();
}

class _WalletTopUpDialogState extends State<WalletTopUpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _focusNode = FocusNode();

  // Predefined amounts in dinars
  final List<double> _predefinedAmounts = [5.0, 10.0, 25.0, 50.0, 100.0];
  double? _selectedAmount;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPredefinedAmounts(),
                  const SizedBox(height: 16),
                  _buildCustomAmountField(),
                  const SizedBox(height: 24),
                  _buildPaymentInfo(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.account_balance_wallet, size: 48, color: AppColors.primary),
        const SizedBox(height: 12),
        Text(
          'شحن المحفظة',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر المبلغ الذي تريد شحنه في محفظتك',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPredefinedAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مبالغ سريعة',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _predefinedAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () => _selectPredefinedAmount(amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.grey100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${amount.toStringAsFixed(0)} د.ع',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أو أدخل مبلغ مخصص',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
          ],
          decoration: InputDecoration(
            hintText: 'المبلغ بالدينار العراقي',
            suffixText: 'د.ع',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          validator: _validateAmount,
          onChanged: (value) {
            setState(() {
              _selectedAmount = null; // Clear predefined selection
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'سيتم توجيهك إلى زين كاش لإتمام عملية الدفع',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitTopUp,
            child: const Text('شحن المحفظة'),
          ),
        ),
      ],
    );
  }

  void _selectPredefinedAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(3);
    });
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      if (_selectedAmount == null) {
        return 'يرجى إدخال المبلغ أو اختيار مبلغ سريع';
      }
      return null;
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'يرجى إدخال مبلغ صحيح';
    }

    if (amount < 1) {
      return 'الحد الأدنى للشحن هو 1 دينار';
    }

    if (amount > 1000) {
      return 'الحد الأقصى للشحن هو 1000 دينار';
    }

    return null;
  }

  void _submitTopUp() {
    if (_formKey.currentState!.validate()) {
      double amount;

      if (_selectedAmount != null) {
        amount = _selectedAmount!;
      } else {
        amount = double.parse(_amountController.text);
      }

      log('💰 Top-up amount: $amount د.ع');

      // Convert to integer (amount is already in dinars)
      final amountInDinars = amount.round();
      log('💰 Amount in dinars: $amountInDinars');

      // Call the callback with amount in dinars
      widget.onTopUp(amountInDinars);
    }
  }
}
