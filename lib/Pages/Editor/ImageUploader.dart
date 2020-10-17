import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:span_builder/span_builder.dart';

import '../../Network/Network.dart';
import '../../Route/Routes.dart';
import '../../Utils/Exts.dart';
import '../../Widgets/w_iconMessage.dart';

class ImageUploader extends StatefulWidget {
  final String attachHash;
  final int uid;
  final int fid;

  ImageUploader(this.attachHash, this.uid, this.fid);

  @override
  State<StatefulWidget> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> with TickerProviderStateMixin {
  List<Uint8List> imageData = [];
  List<Asset> imageList = [];
  List<String> nameList = [];
  List<int> sizeList = [];
  List<String> sizeStringList = [];
  List<Metadata> metaList = [];
  List<String> uploadState = [];
  List<String> uploadStringList = [];
  List<TextSpan> whSpan = [];
  List<TextSpan> sizeSpan = [];
  bool readyState = false;

  bool isMessageShowing = false;
  String message = "";
  IconData icon = Icons.check;
  Color color = Colors.green;
  Map<String, Animation<double>> _fadeAnimation = {};
  Map<String, AnimationController> _fadeController = {};

  _getSize(int value) {
    List sizeSuffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    if (value < 0) {
      return "-" + _getSize(-value);
    }
    if (value == 0) {
      return "0.0 bytes";
    }

    int mag = log(value) ~/ log(1024);
    double adjustedSize = value / (1 << (mag * 10));

    return "${adjustedSize.toStringAsFixed(3)}${sizeSuffixes[mag]}";
  }

  upload() async {
    readyState = false;
    for (int i = 0; i < imageList.length; i++) {
      var size = imageList[i].originalWidth * imageList[i].originalHeight;
      var aspect = imageList[i].originalWidth / imageList[i].originalHeight;
      var data = imageData[i];
      uploadState[i] = "UPLOADING";
      setState(() {});
      if (size > 16777216) {
        final buffer = data.buffer;
        var fileName = (await getTemporaryDirectory()).path + "/" + imageList[i].name;
        await new File(fileName).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

        var oW = imageList[i].originalWidth;
        var oH = imageList[i].originalHeight;
        var targetWidth = (sqrt(16777216) * sqrt(aspect)).toInt();
        var targetHeight = sqrt(16777216) ~/ sqrt(aspect);
        whSpan[i] = TextSpan(
            children: SpanBuilder("尺寸: $oW > $targetWidth * $oH > $targetHeight")
                .apply(TextSpan(text: oW.toString(), style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)))
                .apply(TextSpan(text: oH.toString(), style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)))
                .apply(TextSpan(text: " $targetWidth", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))
                .apply(TextSpan(text: " $targetHeight", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))
                .build());
        setState(() {});
        var f = await FlutterNativeImage.compressImage(fileName, targetWidth: targetWidth, targetHeight: targetHeight, quality: 80);
        var size = _getSize(f.readAsBytesSync().lengthInBytes).toString();
        sizeSpan[i] = TextSpan(
            children: SpanBuilder("大小: ${sizeStringList[i]} > $size")
                .apply(TextSpan(text: sizeStringList[i], style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)))
                .apply(TextSpan(text: size.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))
                .build());
        setState(() {});
        imageData[i] = await f.readAsBytes();
      }
      FormData formData = new FormData.fromMap({"uid": widget.uid, "hash": widget.attachHash, "Filedata": MultipartFile.fromBytes(imageData[i], filename: nameList[i])});
      var response = await NetWork().postMultipart("http://www.ditiezu.com/misc.php?mod=swfupload&operation=upload&hash=${widget.attachHash}&uid=${widget.uid}&type=image&filetype=image&fid=${widget.fid}", formData);
      if (response.isNumeric()) {
        uploadStringList.add(response);
        uploadState[i] = "DONE";
      } else {
        uploadState[i] = "FAILED";
      }
    }
    setState(() {
      isMessageShowing = true;
      message = "上传完成，${uploadState.where((e) {
        return e == "DONE";
      }).length}/${uploadState.length}成功，即将跳转";
      icon = Icons.check;
      color = Colors.green;
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isMessageShowing = false;
        });
      });
    });
    Future.delayed(Duration(seconds: 3), () {
      Routes.pop(context);
    });
  }

  @override
  void initState() {
    _fadeController["main"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeController["messaging"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation["main"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["main"]);
    _fadeAnimation["messaging"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["messaging"]);
    () async {
      imageList = await ImagePicker.pickImages(
        maxImages: 9,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(backgroundColor: "#FFFFFF"),
      );
      for (var i in imageList) {
        var data = (await i.getByteData(quality: 80)).buffer.asUint8List();
        imageData.add(data);
        sizeList.add(data.buffer.lengthInBytes);
        sizeStringList.add(_getSize(data.buffer.lengthInBytes));
        whSpan.add(TextSpan(text: "尺寸: ${imageList[imageList.indexOf(i)].originalWidth} * ${imageList[imageList.indexOf(i)].originalHeight}"));
        sizeSpan.add(TextSpan(text: "大小: ${sizeStringList[imageList.indexOf(i)]}"));
        nameList.add(i.name);
        metaList.add(await i.metadata);
        uploadState.add("PENDING");
      }
      readyState = true;
      setState(() {});
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing,
          child: new FadeTransition(
              opacity: _fadeAnimation["main"],
              child: Container(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                            height: 144,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Stack(children: [
                              Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Row(children: [
                                    Padding(padding: EdgeInsets.only(right: 16), child: Image.memory(imageData[index], height: 100, width: 100, fit: BoxFit.cover)),
                                    Container(
                                        height: 100,
                                        child: Center(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text("第${index + 1}张照片", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          Text.rich(whSpan[index], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          Text.rich(sizeSpan[index], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ])))
                                  ])),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  height: 144,
                                  width: 48,
                                  child: Container(
                                      height: 16,
                                      child: Center(
                                          child: [
                                        Icon(Icons.pending, color: Colors.grey),
                                        SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                        Icon(Icons.done, color: Colors.green),
                                        Icon(Icons.sync_problem, color: Colors.red)
                                      ][["PENDING", "UPLOADING", "DONE", "FAILED"].indexOf(uploadState[index])])))
                            ]));
                      },
                      itemCount: imageList.length)))),
      new Visibility(visible: isMessageShowing, child: new FadeTransition(opacity: _fadeAnimation["messaging"], child: Center(child: IconMessage(icon: icon, color: color, message: message))))
    ]);

    if (isMessageShowing) {
      _fadeController["main"].reverse();
      _fadeController["messaging"].forward();
    } else {
      _fadeController["main"].forward();
      _fadeController["messaging"].reverse();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("上传图片", style: TextStyle(color: Colors.black)),
          leading: MaterialButton(onPressed: () {}, child: Icon(Icons.close, color: Colors.black)),
          actions: [
            MaterialButton(onPressed: readyState ? upload : null, child: Row(children: [Text("开始上传", style: TextStyle(color: readyState ? Colors.black : Colors.grey)), Icon(Icons.sync, color: readyState ? Colors.black : Colors.grey)]))
          ],
        ),
        body: el);
  }
}
