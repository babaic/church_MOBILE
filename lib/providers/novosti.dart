import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:saborna_crkva/models/novost.dart';

import '../globalVar.dart';
import 'package:http/http.dart' as http;

class Novosti with ChangeNotifier {

  List<Novost> _novosti = [];
  List<Uint8List> slike = [];
  int totalPage;
  //final pageNumber = 2;

  List<Novost> get novosti {
    return [..._novosti];
  }
  
  Future<void> getNovosti({int pageNumber, int id}) async {
    //if it's first call clear old data
    if(pageNumber == 1) {
      _novosti = [];
    }
    var url = GlobalVar.apiUrl+'novosti/getnovosti?pageNumber=$pageNumber';
    if(id != null) {
      url+= '&id=$id';
    }

    Map<String, String> headers = {
    'Content-Type': 'application/json;charset=UTF-8',
    'Charset': 'utf-8'
    };

    var result = await http.get(url, headers: headers);
    var extractData = json.decode(result.body);

    List<Novost> novostiToAdd = new List<Novost>();

    totalPage = extractData['totalPage'];
    
    extractData['items'].forEach((novost) {
      novostiToAdd.add(Novost(
        id: novost['id'],
        naslov: novost['naslov'],
        text: novost['text'],
        glavnaSlika: novost['glavnaSlika'],
        datum: novost['datumObjavljivanja'],
        slike: novost['slike']
      ));
    });

    _novosti = _novosti + novostiToAdd;
    notifyListeners();
  }

  Future<void> getImages(int id) async {
    var url = GlobalVar.apiUrl+'novosti/getslike/$id';

    Map<String, String> headers = {
    'Content-Type': 'application/json;charset=UTF-8',
    'Charset': 'utf-8'
    };
    var result = await http.get(url, headers: headers);
    var extractData = json.decode(result.body)['slike'];

    List<Uint8List> slikeGalerija = new List<Uint8List>();

    for(var i = 0; i< extractData.length; i++) {
      slikeGalerija.add(Base64Codec().decode(extractData[i]));
    }

    slike = slikeGalerija;

  }

}