import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/models/obavijest.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globalVar.dart';
import 'package:http/http.dart' as http;

import '../helper.dart';
import 'auth.dart';

class Kategorija {
  final int kategorijaId;
  final String naziv;
  bool isSelected = false;

  Kategorija (this.kategorijaId, this.naziv);
}

class Obavijesti with ChangeNotifier {
  List<Obavijest> _obavijesti = [];
  List<Uint8List> slike = [];
  int totalPage;
  List<Kategorija> _kategorije = [];

  List<Obavijest> get obavijesti {
    return [..._obavijesti];
  }
  List<Kategorija> get kategorije {
    return [..._kategorije];
  }

    Future<void> getObavijesti({int pageNumber, int id, String token}) async {
    //if it's first call clear old data
    if(pageNumber == 1) {
      _obavijesti = [];
      _kategorije = [];
      await getCategories(id, token);
    }
    var url = GlobalVar.apiUrl+'obavjestenja/getobavjestenja?pageNumber=$pageNumber';
    if(id != null) {
      url+= '&kategorijaid=$id';
    }

    //get user role
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final String role = extractedData['role'].toString();
    url+='&role=$role';
    //print(role);
    var result = await http.get(url, headers: GlobalVar.headersToken(token));
    var extractData = json.decode(result.body) as Map<String, dynamic>;

    //print(extractData);

    //print(result.statusCode);

    List<Obavijest> obavijestiToAdd = new List<Obavijest>();

    totalPage = extractData['totalPage'];
    
    extractData['items'].forEach((obavijest) {
      obavijestiToAdd.add(Obavijest(
        id: obavijest['id'],
        naslov: obavijest['naslov'],
        text: obavijest['text'],
        glavnaSlika: obavijest['glavnaSlika'],
        datum: obavijest['datumObjavljivanja'],
        slike: obavijest['slike'],
        kategorija: obavijest['kategorije'],
        kategorijaId: obavijest['kategorijaId'],
      ));
    });

    print(obavijestiToAdd);

    var pismo = await getLocale();

    obavijestiToAdd.forEach((obavijest) {
      String prevodNaslov = '';
      String prevodTekst = '';

      for(var slovo = 0; slovo < obavijest.naslov.length; slovo++) {
        if(pismo.languageCode == 'sr') {
          prevodNaslov+= Helper.convertLatinToCyrillic(obavijest.naslov[slovo]);
        }
        else {
          prevodNaslov+= Helper.convertCyrillicToLatin(obavijest.naslov[slovo]);
        }
      }
      obavijest.naslov = prevodNaslov;

      for(var slovo = 0; slovo < obavijest.text.length; slovo++) {
        if(pismo.languageCode == 'sr') {
          prevodTekst+= Helper.convertLatinToCyrillic(obavijest.text[slovo]);
        }
        else {
          prevodTekst+= Helper.convertCyrillicToLatin(obavijest.text[slovo]);
        }
      }
      obavijest.text = prevodTekst;

    });


    _obavijesti = _obavijesti + obavijestiToAdd;

    notifyListeners();
  }
  
  Future<void> getImages(int id, String token) async {
    var url = GlobalVar.apiUrl+'obavjestenja/getslike/$id';


    var result = await http.get(url, headers: GlobalVar.headersToken(token));
    var extractData = json.decode(result.body)['slike'];

    List<Uint8List> slikeGalerija = new List<Uint8List>();

    for(var i = 0; i< extractData.length; i++) {
      slikeGalerija.add(Base64Codec().decode(extractData[i]));
    }

    slike = slikeGalerija;
    
  }

  Future<void> getCategories(int id, String token) async {
   var url = GlobalVar.apiUrl+'obavjestenja/getkategorije';

    var result = await http.get(url, headers: GlobalVar.headersToken(token));
    var extractData = json.decode(result.body);
    //print(extractData);
    for(var i = 0; i < extractData.length; i++) {
      _kategorije.add(Kategorija(extractData[i]['obavjestenjaKategorijeID'], extractData[i]['naziv']));
    }
    _kategorije.insert(0, Kategorija(0, 'Prikazi sve'));
    changeSelectedCategory(id);
  }

  void changeSelectedCategory(int id) {
    print(id);
    var katOld = _kategorije.firstWhere((element) => element.isSelected == true, orElse: () { return null; });
    if(katOld != null) {
      katOld.isSelected = false;
    }

    var kat = _kategorije.firstWhere((element) => element.kategorijaId == id);
    kat.isSelected = true;

    notifyListeners();
  }
}