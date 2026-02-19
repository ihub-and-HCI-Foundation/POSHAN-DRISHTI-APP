import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poshan_drishti/view/img_preview.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as crop_img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey _boundaryBoxKey = GlobalKey();
  final GlobalKey _cameraScreenKey = GlobalKey();

  CameraController? _camera;
  late Interpreter _interpreter;
  bool leftArmOk = false;
  bool _processing = false;
  bool _processingCapture = false;

  // pose detection(Movenet)

  static const int leftShoulder = 5;
  static const int leftElbow = 7;
  static const int leftWrist = 9;
  // boundary ration
  static const double widthRatio = 0.75;
  static const double heightRatio = 0.40;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _camera = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _camera!.initialize();

    _interpreter = await Interpreter.fromAsset('assets/models/movenet.tflite');

    await _camera!.startImageStream(_processFrame);

    if (mounted) setState(() {});
  }

  // ==========================
  // PROCESS CAMERA FRAME
  // ==========================
  Future<void> _processFrame(CameraImage image) async {
    // print("Camera Page : ${ModalRoute.isCurrentOf(context)}");
    if (!ModalRoute.isCurrentOf(context)!) return;

    if (_processing) return;
    _processing = true;

    try {
      final ui.Image rgbImage = await _yuvToImage(image);
      await _runMoveNet(rgbImage);
    } catch (e) {
      debugPrint("ERROR PROCESSING: $e");
    }

    _processing = false;
  }

  Rect getPreviewRect(Size screen, Size image) {
    final screenRatio = screen.width / screen.height;
    final imageRatio = image.width / image.height;

    if (imageRatio > screenRatio) {
      final previewHeight = screen.width / imageRatio;
      final top = (screen.height - previewHeight) / 2;
      return Rect.fromLTWH(0, top, screen.width, previewHeight);
    } else {
      final previewWidth = screen.height * imageRatio;
      final left = (screen.width - previewWidth) / 2;
      return Rect.fromLTWH(left, 0, previewWidth, screen.height);
    }
  }

  // ==========================
  // RUN MOVENET
  // ==========================
  Future<void> _runMoveNet(ui.Image original) async {
    final resized = await _resizeImage(original, 192, 192);
    final byteData = await resized.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return;

    final pixels = byteData.buffer.asUint8List();

    final input = List.generate(
      1,
      (_) => List.generate(
        192,
        (_) => List.generate(192, (_) => List.filled(3, 0)),
      ),
    );

    int p = 0;
    for (int y = 0; y < 192; y++) {
      for (int x = 0; x < 192; x++) {
        input[0][y][x][0] = pixels[p];
        input[0][y][x][1] = pixels[p + 1];
        input[0][y][x][2] = pixels[p + 2];
        p += 4;
      }
    }

    final List<List<List<List<double>>>> output = List.generate(
      1,
      (_) => List.generate(
        1,
        (_) => List.generate(17, (_) => List.filled(3, 0.0)),
      ),
    );

    _interpreter.run(input, output);

    final kp = output[0][0];

    if (kp[leftShoulder][2] < 0.4 ||
        kp[leftElbow][2] < 0.4 ||
        kp[leftWrist][2] < 0.4) {
      setState(() => leftArmOk = false);
      return;
    }

    final shoulderImg = Offset(
      kp[leftShoulder][1] * original.width,
      kp[leftShoulder][0] * original.height,
    );
    final elbowImg = Offset(
      kp[leftElbow][1] * original.width,
      kp[leftElbow][0] * original.height,
    );
    final wristImg = Offset(
      kp[leftWrist][1] * original.width,
      kp[leftWrist][0] * original.height,
    );

    final screen = MediaQuery.of(context).size;

    final mapped = _mapToScreen(
      originalSize: Size(original.width.toDouble(), original.height.toDouble()),
      screenSize: screen,
      points: [shoulderImg, elbowImg, wristImg],
    );

    final previewRect = getPreviewRect(
      screen,
      Size(original.width.toDouble(), original.height.toDouble()),
    );

    final box = Rect.fromCenter(
      // center: Offset(screen.width * 0.45, screen.height / 2),
      center: previewRect.center,
      width: screen.width * widthRatio,
      height: screen.width * heightRatio,
    );

    setState(() {
      leftArmOk =
          box.contains(mapped[0]) &&
          box.contains(mapped[1]) &&
          box.contains(mapped[2]);
    });
    debugPrint("======leftArmOk=====$leftArmOk");
  }

  // ==========================
  // CAPTURE IMAGE
  // ==========================
  Future<void> _capture() async {
    if (!leftArmOk || _processingCapture) return;
    _processingCapture = true;

    final XFile file = await _camera!.takePicture();
    final Uint8List fullBytes = await file.readAsBytes();

    // final Size screenSize = MediaQuery.of(context).size;
    final ui.Image decoded = await decodeImageFromList(fullBytes);

    //  Camera preview rect on screen
    // final Rect previewRect = getPreviewRect(
    //   screenSize,
    //   Size(decoded.width.toDouble(), decoded.height.toDouble()),
    // );

    // SAME boundary box used for validation
    // final Rect boundaryBox = Rect.fromCenter(
    //   center: previewRect.center,
    //   //  center: Offset(screenSize.width * 0.45, screenSize.height / 2),
    //   width: screenSize.width * widthRatio,
    //   height: screenSize.width * heightRatio,
    // );

    //final ui.Image decoded = await decodeImageFromList(fullBytes);

    final Uint8List croppedBytes = await cropToBoundaryBox(
      imageBytes: fullBytes,
      imageSize: Size(decoded.width.toDouble(), decoded.height.toDouble()),
    );
    _processingCapture = false;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImgPreview(imageBytes: croppedBytes)),
    );
  }

  // ==========================
  // MAP IMAGE → SCREEN
  // ==========================
  List<Offset> _mapToScreen({
    required Size originalSize,
    required Size screenSize,
    required List<Offset> points,
  }) {
    final imageAspect = originalSize.width / originalSize.height;
    final screenAspect = screenSize.width / screenSize.height;

    double scale, dx, dy;

    if (screenAspect > imageAspect) {
      scale = screenSize.height / originalSize.height;
      dx = (screenSize.width - originalSize.width * scale) / 2;
      dy = 0;
    } else {
      scale = screenSize.width / originalSize.width;
      dx = 0;
      dy = (screenSize.height - originalSize.height * scale) / 2;
    }

    return points
        .map((p) => Offset(p.dx * scale + dx, p.dy * scale + dy))
        .toList();
  }

  // ==========================
  // YUV → RGB
  // ==========================
  Future<ui.Image> _yuvToImage(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final Uint8List rgba = Uint8List(width * height * 4);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * yRowStride + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int Y = yBuffer[yIndex];
        final int U = uBuffer[uvIndex];
        final int V = vBuffer[uvIndex];

        int r = (Y + 1.370705 * (V - 128)).round();
        int g = (Y - 0.337633 * (U - 128) - 0.698001 * (V - 128)).round();
        int b = (Y + 1.732446 * (U - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        final int rgbaIndex = (y * width + x) * 4;
        rgba[rgbaIndex] = r;
        rgba[rgbaIndex + 1] = g;
        rgba[rgbaIndex + 2] = b;
        rgba[rgbaIndex + 3] = 255;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  Future<ui.Image> _resizeImage(ui.Image image, int w, int h) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint(),
    );
    return recorder.endRecording().toImage(w, h);
  }

  Future<Uint8List> cropToBoundaryBox({
    required Uint8List imageBytes,
    required Size imageSize,
  }) async {
    final Size boundaryBoxSize =
        _boundaryBoxKey.currentContext!.size ?? Size.zero;
    final boundaryRenderBox =
        _boundaryBoxKey.currentContext!.findRenderObject() as RenderBox;

    final boundaryBoxPos = boundaryRenderBox.localToGlobal(
      Offset.zero,
    ); // The offset from top and left of the screen in screen-space

    final Size cameraScreenSize =
        _cameraScreenKey.currentContext!.size ?? Size.zero;

    crop_img.Image? crpImage = crop_img.decodeImage(imageBytes);

    crop_img.Image croppedImage = crop_img.copyCrop(
      crpImage!,
      x: (boundaryBoxPos.dx * (imageSize.width / cameraScreenSize.width))
          .toInt(),
      y: (boundaryBoxPos.dy * (imageSize.height / cameraScreenSize.height))
          .toInt(),
      width:
          (boundaryBoxSize.width *
                  (imageSize.width /
                      cameraScreenSize
                          .width)) // The ratio between visible camera screen size and image size
              .toInt(),
      height:
          (boundaryBoxSize.height *
                  (imageSize.height / cameraScreenSize.height))
              .toInt(),
    );

    Uint8List croppedBytes = crop_img.encodePng(croppedImage);
    return croppedBytes;
  }

  // Future<Uint8List> cropToBoundaryBox({
  //   required Uint8List imageBytes,
  //   required Size imageSize,
  //   required Size screenSize,
  //   required Rect boundaryBox,
  // }) async {
  //   final ui.Image image = await decodeImageFromList(imageBytes);
  //   final previewRect = getPreviewRect(screenSize, imageSize);

  //   final scaleX = image.width / previewRect.width;
  //   final scaleY = image.height / previewRect.height;

  //   // Scale factors (screen → image)
  //   // final scaleX = image.width / screenSize.width;
  //   // final scaleY = image.height / screenSize.height;

  //   /* final Rect cropRect = Rect.fromLTWH(
  //     boundaryBox.left * scaleX,
  //     boundaryBox.top * scaleY,
  //     boundaryBox.width * scaleX,
  //     boundaryBox.height * scaleY,
  //   ); */

  //   final Rect cropRect = Rect.fromLTWH(
  //     (boundaryBox.left - previewRect.left) * scaleX,
  //     (boundaryBox.top - previewRect.top) * scaleY,
  //     boundaryBox.width * scaleX,
  //     boundaryBox.height * scaleY,
  //   );

  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder);

  //   canvas.drawImageRect(
  //     image,
  //     cropRect,
  //     Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
  //     Paint(),
  //   );

  //   final ui.Image cropped = await recorder.endRecording().toImage(
  //     cropRect.width.toInt(),
  //     cropRect.height.toInt(),
  //   );

  //   final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);

  //   return byteData!.buffer.asUint8List();
  // }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    if (_camera == null || !_camera!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            key: _cameraScreenKey,
            child: CameraPreview(_camera!),
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    key: _boundaryBoxKey,
                    width: screen.width * widthRatio,
                    height: screen.width * heightRatio,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: leftArmOk ? Colors.green : Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    constraints: BoxConstraints.expand(width: 76),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const ui.Color.fromARGB(188, 255, 255, 255),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Center(
                        child: IconButton(
                          iconSize: 62,
                          onPressed: leftArmOk ? _capture : null,
                          icon: Icon(
                            Icons.camera_alt,
                            color: leftArmOk ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _camera!.dispose();
    _interpreter.close();
    super.dispose();
  }
}
