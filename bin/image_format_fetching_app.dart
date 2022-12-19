import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
class ServerResponse {
  String? type;
  Targets? targets;

  ServerResponse({this.type, this.targets});

  ServerResponse.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    targets =
    json['targets'] != null ? Targets.fromJson(json['targets']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (targets != null) {
      data['targets'] = targets!.toJson();
    }
    return data;
  }
}

class Targets {
  List<Image>? image;
  List<Image>? document;

  Targets({this.image, this.document});

  Targets.fromJson(Map<String, dynamic> json) {
    if (json['image'] != null) {
      image = <Image>[];
      json['image'].forEach((v) {
        image!.add(Image.fromJson(v));
      });
    }
    if (json['document'] != null) {
      document = <Image>[];
      json['document'].forEach((v) {
        document!.add(Image.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (image != null) {
      data['image'] = image!.map((v) => v.toJson()).toList();
    }
    if (document != null) {
      data['document'] = document!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Image {
  String? name;
  String? slug;
  String? intExt;
  String? outExt;
  String? type;
  bool? device;
  bool canConvertLocallyOnIos = false;
  bool canConvertLocallyOnAndroid = false;

  Image({this.name, this.slug, this.outExt,this.intExt, this.type, this.device, this.canConvertLocallyOnIos=false, this.canConvertLocallyOnAndroid=false});

  Image.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    intExt = json['inputExt'];
    outExt = json['ext'];
    type = json['type'];
    device = json['device'];
    canConvertLocallyOnIos = json['canConvertLocallyOnIos']??false;
    canConvertLocallyOnAndroid = json['canConvertLocallyOnAndroid']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['inputExt'] = intExt;
    data['ext'] = outExt;
    data['type'] = type;
    data['device'] = device;
    data['canConvertLocallyOnIos'] = canConvertLocallyOnIos;
    data['canConvertLocallyOnAndroid'] = canConvertLocallyOnAndroid;
    return data;
  }
}

void main(List<String> arguments) async{
  http.Client client = http.Client();

  List<String> inputs =  [
    "art",
    "arw",
    "bmp",
    "crw",
    "cbr",
    "cbz",
    "cr2",
    "crw",
    "dcr",
    "dcs",
    "dds",
    "dib",
    "djv",
    "djvu",
    "dng",
    "dpx",
    "drf",
    "emf",
    "emz",
    "eps",
    "gif",
    "heic",
    "ico",
    "jfif",
    "jpeg",
    "jpg",
    "k25",
    "kdc",
    "dcs",
    "rwl",
    "nef",
    "nrw",
    "raw",
    "pcx",
    "pef",
    "png",
    "ppm",
    "psb",
    "psd",
    "ptx",
    "raf",
    "raw",
    "rw2",
    "rwl",
    "srw",
    "x3f",
    "arw",
    "sr2",
    "srf",
    "srw",
    "svg",
    "tga",
    "tif",
    "tiff",
    "webp",
    "wmf",
    "wmz",
    "x3f",
    "pdf",
  ];
  List<Image> outputs = [];

  await Future.forEach<String>(InputExtension.values.map((e) => e.getExtString()), (i)async{
    var localSupportInputExt = LocalSupportedInputExtension.values.firstWhere((ext) => ext.getExtString() == i,orElse: ()=> LocalSupportedInputExtension.none);

    await client.get(Uri.parse("https://api.freeconvert.com/v1/query/view/options?operation=convert&input_format=$i")).then((value){
      if(value.statusCode != 200) throw Exception(value.body);

      var res = ServerResponse.fromJson(jsonDecode(value.body));

      List<Image> targetList = [];
      targetList.addAll(res.targets?.image??[]);
      targetList.addAll(res.targets?.document??[]);
      targetList.forEach((Image element) {
        element.intExt = i;

        if(!outputs.any((e) => e.intExt == element.intExt && e.outExt?.toLowerCase() == element.outExt?.toLowerCase())){
          var localSupportOutExt = LocalSupportedOutputExtension.values.firstWhere((ext) => ext.getExtString() == element.outExt,orElse: ()=> LocalSupportedOutputExtension.none);


          element.canConvertLocallyOnAndroid = localSupportInputExt != LocalSupportedInputExtension.none &&
              (localSupportInputExt.getSupportedOS() == SupportedOS.android || localSupportInputExt.getSupportedOS() == SupportedOS.both) &&
              localSupportOutExt != LocalSupportedOutputExtension.none;



          element.canConvertLocallyOnIos = localSupportInputExt != LocalSupportedInputExtension.none &&
              (localSupportInputExt.getSupportedOS() == SupportedOS.ios || localSupportInputExt.getSupportedOS() == SupportedOS.both) &&
              localSupportOutExt != LocalSupportedOutputExtension.none;

          outputs.add(element);
        }
      });

    }).catchError((e){
      print(e);
    });
  });

  // print(inputs.map((e) => e).join(","));
  //print(outputs.map((e) => e.ext));
  outputs.forEach((element) {
    print(element.toJson().toString());
  });

  var data = jsonEncode(outputs);
  print(data);
}




enum InputExtension{
  art,arw,bmp,crw,cbr,cbz,cr2,cr3,dcr,dcs,dds,dib,djv,djvu,dng,dpx,drf,emf,emz,eps,gif,avif,heic,ico,jfif,jpeg,jpg,k25,kdc,rwl, nef,nrw,raw,pcx,pef,png,ppm,psb,psd,ptx,raf,rw2,srw,x3f,sr2,srf,svg,tga,tif,tiff,webp,wmf,wmz,pdf;

  String getExtString(){
    return name.toLowerCase();
  }

  /// Check supported platform for local conversion
  SupportedOS getSupportedOS() {
    switch(this){
      case InputExtension.cr2: return SupportedOS.ios;
      case InputExtension.cr3: return SupportedOS.ios;
      case InputExtension.crw: return SupportedOS.ios;
      case InputExtension.avif: return SupportedOS.ios;
      default: return SupportedOS.both;
    }
  }
}
enum OutputExtension{
  jpg, psd, bmp, tiff, png, gif, webp, svg, odd, eps, ico, tga;

  String getExtString(){
    return name.toLowerCase();
  }
  String getNameString(){
    return name.toUpperCase();
  }
}

enum LocalSupportedInputExtension{
  jpg, png, bmp, gif, webp, ico, pdf, dib, heic, tiff, tif, tga, svg, cr2, cr3, nef, dng, psd, psb, crw, iiq, nrw, pef, avif, raf, kdc, rw2, rwl, none;

  String getExtString(){
    return name.toLowerCase();
  }

  SupportedOS getSupportedOS() {
    switch(this){
      case LocalSupportedInputExtension.cr2: return SupportedOS.ios;
      case LocalSupportedInputExtension.cr3: return SupportedOS.ios;
      case LocalSupportedInputExtension.crw: return SupportedOS.ios;
      case LocalSupportedInputExtension.avif: return SupportedOS.ios;
      default: return SupportedOS.both;
    }
  }
}
enum LocalSupportedOutputExtension {
  jpg, png, bmp, gif, webp, ico, pdf, none;

  String getExtString(){
    return name.toLowerCase();
  }

  String getNameString(){
    return name.toUpperCase();
  }
}

enum SupportedOS{
  android, ios, both;

  ///Get current platform
  static SupportedOS getCurrentOS(){
    if (Platform.isAndroid) {
      return SupportedOS.android;
    } else if (Platform.isIOS){
      return SupportedOS.ios;
    }else{
      throw Exception("Platform not supported!");
    }
  }
}