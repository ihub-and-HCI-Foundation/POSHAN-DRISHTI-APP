import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:poshan_drishti/view/camera_screen.dart';
import 'package:poshan_drishti/widget/input_field.dart';
import 'package:poshan_drishti/widget/selection_field.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Information'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        // iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[100]!,
        width: double.infinity,
        height: double.infinity,
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 2,
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      name: 'age',
                      keyboardType: TextInputType.none,
                      inputAction: TextInputAction.next,
                      titleIcon: Icons.child_care,
                      prefixIcon: Icons.child_care, // added age icon as suffix
                      title: 'Age in months',
                      addStar: '*',
                      hint: 'Enter Age in months',
                      validatorRequired: true,
                      readOnly: false,
                      maxLines: 1,
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 12),
                    SelectionField(
                      name: 'gender',
                      title: 'Gender',
                      hint: 'Select Gender',
                      options: ['Male', 'Female', 'Other'],
                      isValidationRequired: true,
                      isEnable: true,
                      isSpaceRequired: false,
                      height: 0,
                      isRequiredToDisable: false,
                      titleIcon: Icons.person,
                      addStar: '*',
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 12),
                    InputField(
                      name: 'height',
                      title: 'Height in cm',
                      keyboardType: TextInputType.none,
                      inputAction: TextInputAction.next,
                      titleIcon: Icons.height,
                      prefixIcon: Icons.height, // added height icon as suffix
                      addStar: '*',
                      hint: 'Enter Height in cm',
                      validatorRequired: true,
                      readOnly: false,
                      maxLines: 1,
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 12),
                    InputField(
                      name: 'muac',
                      title: 'MUAC in mm',
                      keyboardType: TextInputType.none,
                      inputAction: TextInputAction.next,
                      titleIcon: Icons.straighten,
                      prefixIcon:
                          Icons.straighten, // added height icon as suffix
                      addStar: '*',
                      hint: 'Enter MUAC in mm',
                      validatorRequired: true,
                      readOnly: false,
                      maxLines: 1,
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 12),
                    SelectionField(
                      name: 'nutrition_status',
                      title: 'Nutrition Status',
                      hint: 'Select Nutrition Status',
                      options: ['MAM', 'SAM', 'NORMAL'],
                      isValidationRequired: true,
                      isEnable: true,
                      isSpaceRequired: false,
                      height: 0,
                      isRequiredToDisable: false,
                      titleIcon: Icons.local_dining,
                      addStar: '*',
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 12),
                    SelectionField(
                      name: 'oedema_status',
                      title: 'Oedema Status',
                      hint: 'Select Oedema Status',
                      options: ['YES', 'NO'],
                      isValidationRequired: true,
                      isEnable: true,
                      isSpaceRequired: false,
                      height: 0,
                      isRequiredToDisable: false,
                      titleIcon: Icons.healing,
                      addStar: '*',
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text("Capture Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            Get.to(() => CameraScreen());
                            // Implement your capture image functionality here
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
