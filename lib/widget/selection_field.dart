import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectionField extends StatelessWidget {
  final String name;
  final String title;
  final String hint;
  final List<String> options;
  final String? initialValue;
  final bool? isEnable;
  final bool? isValidationRequired;
  final ValueChanged<String?> onChanged;
  final IconData? titleIcon;
  final IconData? prefixIcon;
  final String? addStar;
  final bool? isSpaceRequired;
  final double? height;
  final bool? isRequiredToDisable;

  const SelectionField({
    super.key,
    required this.name,
    required this.title,
    required this.options,
    required this.hint,
    this.initialValue,
    this.isEnable = true,
    required this.isValidationRequired,
    required this.onChanged,
    this.titleIcon,
    this.addStar,
    this.prefixIcon,
    this.isSpaceRequired = false,
    this.height,
    this.isRequiredToDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isRequiredToDisable!
            ? SizedBox.shrink()
            : Row(
                children: [
                  if (isSpaceRequired!) SizedBox(height: height ?? 0),
                  Icon(titleIcon, color: Colors.blue[400], size: 16),
                  SizedBox(width: 3),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall,
                            softWrap: true,
                            maxLines: 2,
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
                    ) /*  */,
                  ),
                ],
              ),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: FormBuilderDropdown<String>(
            name: name,
            isDense: true,
            isExpanded: true,
            enabled: isEnable! ? true : false,
            icon: SizedBox.shrink(),
            items: options
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefix: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.grey[700])
                  : null,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5), // perfect rectangle
                borderSide: BorderSide(color: Colors.grey[500]!, width: 1.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey[500]!, width: 1.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.blue[900]!, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red),
              ),
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500]!.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              hint: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hint,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey[500]!,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            validator: isValidationRequired!
                ? FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Please select $title',
                    ),
                  ])
                : null,
            style: Theme.of(context).textTheme.titleSmall,
            initialValue: initialValue,
          ),
        ),
      ],
    );
  }
}
