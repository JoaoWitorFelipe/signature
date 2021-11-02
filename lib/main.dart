import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/signature_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Signature'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset?> signatureOffsets = [];
  ByteData? byteImageFromCanvas;

  static const double canvasWidth = 200.0;
  static const double canvasHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
              ),
              child: GestureDetector(
                onPanEnd: endUpdateCanvas,
                onPanUpdate: updateCanvas,
                child: CustomPaint(
                  size: const Size(canvasWidth, canvasHeight),
                  painter: SignaturePainter(offsets: signatureOffsets),
                ),
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  child: const Text("SAVE SIGNATURE"),
                  onPressed: generateImageFromCanvas,
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  child: const Text("CLEAN SIGNATURE"),
                  onPressed: cleanCanvas,
                ),
              ],
            ),
            byteImageFromCanvas != null
                ? Column(
                    children: <Widget>[
                      const Text("YOUR IMAGE SIGNATURE"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        child: Image.memory(
                          Uint8List.view(byteImageFromCanvas!.buffer),
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void updateCanvas(details) {
    setState(() {
      byteImageFromCanvas = null;
    });
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    final insideRightSide = dx < canvasWidth;
    final insideBottomSide = dy < canvasHeight;
    final insideTopSide = (dy > 0) && dy >= (canvasHeight * (-1));
    final insideLeftSide = (dx > 0) && dx >= (canvasWidth * (-1));
    final isInsideCanvas =
        insideRightSide && insideLeftSide && insideBottomSide && insideTopSide;

    if (isInsideCanvas) {
      setState(() {
        signatureOffsets.add(details.localPosition);
      });
    }
  }

  void endUpdateCanvas(_) {
    setState(() {
      signatureOffsets.add(null);
    });
  }

  void cleanCanvas() {
    setState(() {
      byteImageFromCanvas = null;
      signatureOffsets = [];
    });
  }

  void generateImageFromCanvas() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0.0, 0.0),
        const Offset(canvasWidth, canvasHeight),
      ),
    );

    for (int i = 0; i < signatureOffsets.length; i++) {
      final offset = signatureOffsets[i];
      final nextIndex = i + 1;

      if (offset != null && nextIndex <= (signatureOffsets.length - 1)) {
        final nextOffset = signatureOffsets[nextIndex];
        if (nextOffset != null) {
          canvas.drawLine(
            offset,
            nextOffset,
            Paint()..color = Colors.black,
          );
        }
      } else if (offset != null) {
        canvas.drawPoints(
          PointMode.lines,
          [offset],
          Paint()..color = Colors.black,
        );
      }
    }

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    setState(() {
      byteImageFromCanvas = bytes;
    });
  }
}
