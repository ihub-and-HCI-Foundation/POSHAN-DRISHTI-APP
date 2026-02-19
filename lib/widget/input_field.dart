import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:poshan_drishti/widget/input_style.dart';

class InputField extends StatelessWidget {
  final String name;
  final String? title; // small text shown above input
  final String? hint;
  final TextInputType? keyboardType;
  final bool validatorRequired;
  final String? initialValue;
  final bool readOnly;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputAction? inputAction;
  final ValueChanged<String?>? onChanged;
  final IconData? titleIcon;
  final String? addStar;
  final bool onlyInteger;
  final int? maxLength;
  final bool? isRequiredToDisable;

  const InputField({
    super.key,
    required this.name,
    this.title,
    this.hint,
    this.keyboardType,
    this.validatorRequired = false,
    this.initialValue,
    //this.inputFormatters,
    required this.readOnly,
    this.suffixIcon,
    this.prefixIcon,
    required this.maxLines,
    this.onChanged,
    this.titleIcon,
    this.addStar,
    this.inputAction,
    this.onlyInteger = false,
    this.maxLength,
    this.isRequiredToDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isRequiredToDisable!
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Icon(titleIcon, color: Colors.blue[400], size: 16),
                    SizedBox(width: 3),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title ?? '',
                              style: Theme.of(context).textTheme.titleSmall,
                              softWrap: true,
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if ((addStar ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                addStar!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 5),
          FormBuilderTextField(
            name: name,
            readOnly: readOnly,
            initialValue: initialValue,
            maxLines: maxLines,
            cursorColor: Colors.blue[900],
            keyboardType: keyboardType,
            textInputAction: inputAction,
            inputFormatters: [
              if (onlyInteger) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength!),
            ],
            validator: validatorRequired
                ? FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Please Enter $title',
                    ),
                  ])
                : null,
            decoration: InputStyle.normalInput(
              hint: hint,
              prefixIcon: prefixIcon,
              suffix: suffixIcon,
            ),
            onChanged: onChanged,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
