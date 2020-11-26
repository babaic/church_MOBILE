import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/models/novost.dart';

import '../globalVar.dart';
import 'package:http/http.dart' as http;

import '../helper.dart';

class Novosti with ChangeNotifier {

  List<Novost> _novosti = [];
  List<Uint8List> slike = [];
  int totalPage;
  //final pageNumber = 2;

  List<Novost> get novosti {
    return [..._novosti];
  }
  
  Future<void> getNovosti({int pageNumber, int id, String token}) async {
    //if it's first call clear old data
    if(pageNumber == 1) {
      _novosti = [];
    }
    var url = GlobalVar.apiUrl+'novosti/getnovosti?pageNumber=$pageNumber';
    if(id != null) {
      url+= '&id=$id';
    }

    var result = await http.get(url, headers: GlobalVar.headersToken(token));
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

    var pismo = await getLocale();

    novostiToAdd.forEach((novost) {
      String prevodNaslov = '';
      String prevodTekst = '';

      for(var slovo = 0; slovo < novost.naslov.length; slovo++) {
        if(pismo.languageCode == 'sr') {
          prevodNaslov+= Helper.convertLatinToCyrillic(novost.naslov[slovo]);
        }
        else {
          prevodNaslov+= Helper.convertCyrillicToLatin(novost.naslov[slovo]);
        }
      }
      novost.naslov = prevodNaslov;

      for(var slovo = 0; slovo < novost.text.length; slovo++) {
        if(pismo.languageCode == 'sr') {
          prevodTekst+= Helper.convertLatinToCyrillic(novost.text[slovo]);
        }
        else {
          prevodTekst+= Helper.convertCyrillicToLatin(novost.text[slovo]);
        }
      }
      novost.text = prevodTekst;

    });

    _novosti = _novosti + novostiToAdd;
    notifyListeners();
  }

  Future<void> getImages(int id, String token) async {
    var url = GlobalVar.apiUrl+'novosti/getslike/$id';

    var result = await http.get(url, headers: GlobalVar.headersToken(token));
    var extractData = json.decode(result.body)['slike'];

    List<Uint8List> slikeGalerija = new List<Uint8List>();

    for(var i = 0; i< extractData.length; i++) {
      slikeGalerija.add(Base64Codec().decode(extractData[i]));
    }

    slike = slikeGalerija;

  }

}