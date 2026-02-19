import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:path_provider/path_provider.dart';

class ImgPreview extends StatefulWidget {
  final Uint8List imageBytes;

  const ImgPreview({super.key, required this.imageBytes});

  @override
  State<ImgPreview> createState() => _ImgPreviewState();
}

class _ImgPreviewState extends State<ImgPreview> {
  bool _fullscreenPreview = false;

  Future<void> _saveImage(BuildContext context) async {
    final Directory? baseDir = await getExternalStorageDirectory();
    if (baseDir == null) return;

    final String rootPath = baseDir.path.split('Android')[0];
    final Directory folder = Directory('$rootPath/Pictures/SAM_LeftArm');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final String path =
        '${folder.path}/left_arm_${DateTime.now().millisecondsSinceEpoch}.png';

    await File(path).writeAsBytes(widget.imageBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image saved"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12),
      ),
    );
    //Navigator.pop(context); // back to camera
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _fullscreenPreview
          ? null
          : AppBar(
              title: const Text("Preview"),
              backgroundColor: Colors.transparent,
            ),
      body: Stack(
        children: [
          //SizedBox(height: MediaQuery.paddingOf(context).top),
          Center(
            child: Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: _fullscreenPreview
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height - 92,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _fullscreenPreview = !_fullscreenPreview;
                    });
                  },
                  child: Image.memory(
                    widget.imageBytes,
                    fit: BoxFit.contain, // or BoxFit.cover
                  ),
                ),
              ),
            ),
          ),

          Visibility(
            maintainState: true,
            maintainAnimation: true,
            visible: !_fullscreenPreview,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      label: const Text(
                        "Retake",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.transparent,
                        textStyle: const TextStyle(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => _saveImage(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
