import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'custom_form_field_model.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

enum FormType { text, number, password, datetime, dropdown, file }

class CustomFormField extends StackedView<CustomFormFieldModel> {
  const CustomFormField({
    required this.label,
    required this.formType,
    this.controller,
    super.key,
    this.validator,
    this.isRequired = false,
    this.inputFormatters,
    this.readOnly = false,
    this.showLabel = true,
    this.height,
    // Dropdown-specific
    this.dropdownItems,
    this.onDropdownChanged,
    this.dropdownValue,
    // Datetime-specific
    this.onDateTimeChanged,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    // File-specific
    this.onFilePicked,
    this.onFileDelete,
    this.fileName,
    // Text-specific
    this.minLines,
    this.maxLines,
    this.hintText,
  });

  final String label;
  final FormType formType;
  final bool showLabel;
  final double? height;
  final TextEditingController? controller;
  final FormFieldValidator<dynamic>? validator;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  // Dropdown
  final List<DropdownMenuItem<dynamic>>? dropdownItems;
  final ValueChanged<dynamic>? onDropdownChanged;
  final dynamic dropdownValue;

  // Datetime
  final ValueChanged<DateTime?>? onDateTimeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  // File
  final VoidCallback? onFilePicked;
  final VoidCallback? onFileDelete;
  final String? fileName;

  // Text
  final int? minLines;
  final int? maxLines;
  final String? hintText;

  @override
  Widget builder(
    BuildContext context,
    CustomFormFieldModel viewModel,
    Widget? child,
  ) {
    final textColor = readOnly ? AppColors.textHint : AppColors.textPrimary;

    final containerChild = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label text
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          // Field area
          _buildField(context, Colors.white, textColor),
        ],
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: containerChild,
      );
    }
    return containerChild;
  }

  Widget _buildField(BuildContext context, Color bg, Color textColor) {
    switch (formType) {
      case FormType.number:
      case FormType.text:
      case FormType.password:
        return _buildTextField(context, bg, textColor);
      case FormType.datetime:
        return _buildDateTimeField(context, bg, textColor);
      case FormType.dropdown:
        return _buildDropdownField(context, bg, textColor);
      case FormType.file:
        return _buildFileField(context, bg, textColor);
    }
  }

  Widget _buildTextField(BuildContext context, Color bg, Color textColor) {
    TextInputType keyboardType = TextInputType.text;
    bool obscure = false;
    if (formType == FormType.number) keyboardType = TextInputType.number;
    if (formType == FormType.password) obscure = true;

    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscure,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines ?? (minLines ?? 1),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
      decoration: _inputDecoration(context, bg, hintText: hintText),
    );
  }

  Widget _buildDateTimeField(BuildContext context, Color bg, Color textColor) {
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (picked != null) {
                controller?.text = '${picked.toLocal()}'.split(' ')[0];
                if (onDateTimeChanged != null) onDateTimeChanged!(picked);
              }
            },
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textColor),
          decoration: _inputDecoration(context, bg,
              suffixIcon: const Icon(Icons.calendar_today)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, Color bg, Color textColor) {
    return DropdownButtonFormField<dynamic>(
      initialValue: dropdownValue,
      items: dropdownItems,
      onChanged: readOnly ? null : onDropdownChanged,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
      decoration: _inputDecoration(context, bg),
      isExpanded: true,
    );
  }

  Widget _buildFileField(BuildContext context, Color bg, Color textColor) {
    final hasFile = fileName != null && fileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasFile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined),
                UIHelpers.horizontalSpace16,
                Expanded(child: Text(fileName!)),
                if (!readOnly && onFileDelete != null)
                  IconButton(
                      onPressed: onFileDelete, icon: const Icon(Icons.close)),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  readOnly: true,
                  decoration: _inputDecoration(context, bg, hintText: hintText),
                ),
              ),
              UIHelpers.horizontalSpace16,
              ElevatedButton.icon(
                onPressed: readOnly ? null : onFilePicked,
                icon: const Icon(Icons.upload_file),
                label: const Text('Add'),
              ),
            ],
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, Color fillColor,
      {Widget? suffixIcon, String? hintText}) {
    return InputDecoration(
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textHint),
    );
  }

  @override
  CustomFormFieldModel viewModelBuilder(BuildContext context) =>
      CustomFormFieldModel();
}
