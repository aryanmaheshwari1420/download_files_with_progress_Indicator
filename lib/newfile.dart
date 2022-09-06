import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DOWNLOAD extends StatefulWidget {
  const DOWNLOAD({Key? key}) : super(key: key);

  @override
  State<DOWNLOAD> createState() => _DOWNLOADState();
}

class _DOWNLOADState extends State<DOWNLOAD> {
   String ?progress;
  bool _isLoading = false;
   Dio ?dio;
  @override
  void initState() {
    dio = Dio();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download and Open"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Center(
                child: Center(
                  child: ElevatedButton(
                      child: Text("Download and open"),
                      onPressed: () => openFile(
                          url:
                              "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4",
                          fileName: 'dummy.mp4'),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future openFile({required String url, String? fileName}) async {
    final file = await downloadFile(url, fileName!);
    if (file == null) return;
    print('Path:${file.path}');

    OpenFile.open(file.path);
     
   
    
  }

  Future<File?> downloadFile(String url, String name) async {
    final appstorage = await getApplicationDocumentsDirectory();
    final file = File('${appstorage.path}/$name');
         await dio?.download(url, file.path, onReceiveProgress: (rec, total) {
        setState(() {
          _isLoading = true;
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
          print(progress);
          

        });
      });
    try {
      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0,
          ));

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      return null;
    }
  }
}
