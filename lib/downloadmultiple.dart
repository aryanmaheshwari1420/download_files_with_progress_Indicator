// @dart = 2.9
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pw;
import 'package:download_pdfs/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter download',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _filefullpath;
  String progress;
  bool _isLoading = false;
  final urlpdf = "http://www.africau.edu/images/default/sample.pdf";

  Dio dio;
  @override
  void initState() {
    dio = Dio();
    super.initState();
  }

  Future<List<Directory>> _getExternalStoragePath() {
    return pw.getExternalStorageDirectories(
        type: pw.StorageDirectory.documents);
  }

  Future _downloadAndSaveFileToStorage(
      BuildContext context, String urlpath, String filename) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context, type: ProgressDialogType.normal);

    pr.style(message: "Download file....");

    try {
      await pr.show();
      final dirList = await _getExternalStoragePath();
      final path = dirList[0].path;
      final file = File('$path/filename');
      await dio.download(urlpath, file.path, onReceiveProgress: (rec, total) {
        setState(() {
          _isLoading = true;
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
          print(progress);

          pr.update(message: "Please wait:$progress");
        });
      });
      pr.hide();
      _filefullpath = file.path;
    } catch (e) {
      print(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloading"),
      ),
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    _downloadAndSaveFileToStorage(
                        context, urlpdf, "document.pdf");
                  },
                  child: Text("Write to external storage")),
              Text("Written: $_filefullpath")
            ],
          ),
        ),
      ),
    );
  }
}
