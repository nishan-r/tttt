import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:ttteet/sample_animation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _recording = false;
  bool _exporting = false;
  ScreenRecorderController controller = ScreenRecorderController();
  bool get canExport => controller.exporter.hasFrames;

  int itemLength = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              itemLength++;
            });
          }, icon: Icon(Icons.add)),

          IconButton(onPressed: (){
            setState(() {
              itemLength--;
            });
          }, icon: Icon(Icons.remove))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_exporting)
                const Center(child: CircularProgressIndicator())
              else ...[
                ScreenRecorder(
                  height: 500,
                  width: 500,
                  controller: controller,
                  child: Container(
                    height: 500,width: 300,
                    color: Colors.teal,
                    child: ListView.builder(
                      itemCount: itemLength,
                      itemBuilder: (BuildContext context, int index) {
                        return CircleAvatar();
                      },
                    ),
                  ),
                ),
                if (!_recording && !_exporting)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.start();
                        setState(() {
                          _recording = true;
                        });
                      },
                      child: const Text('Start'),
                    ),
                  ),
                if (_recording && !_exporting)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.stop();
                        setState(() {
                          _recording = false;
                        });
                      },
                      child: const Text('Stop'),
                    ),
                  ),
                if (canExport && !_exporting)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _exporting = true;
                        });
                        var frames = await controller.exporter.exportFrames();
                        if (frames == null) {
                          throw Exception();
                        }
                        setState(() => _exporting = false);
                        showDialog(
                          context: context as dynamic,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                height: 500,
                                width: 500,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: frames.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final image = frames[index].image;
                                    return SizedBox(
                                      height: 150,
                                      child: Image.memory(
                                        image.buffer.asUint8List(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Export as frames'),
                    ),
                  ),
                if (canExport && !_exporting) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _exporting = true;
                        });
                        var gif = await controller.exporter.exportGif();
                        if (gif == null) {
                          throw Exception();
                        }
                        setState(() => _exporting = false);
                        showDialog(
                          context: context as dynamic,
                          builder: (context) {
                            return AlertDialog(
                              content: Image.memory(Uint8List.fromList(gif)),
                            );
                          },
                        );
                      },
                      child: const Text('Export as GIF'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          controller.exporter.clear();
                        });
                      },
                      child: const Text('Clear recorded data'),
                    ),
                  )
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}