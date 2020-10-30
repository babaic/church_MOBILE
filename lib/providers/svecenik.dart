import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:saborna_crkva/globalVar.dart';
import 'package:http/http.dart' as http;
import 'package:saborna_crkva/models/svecenik.dart';


class Svecenik with ChangeNotifier {

  List<SvecenikModel> _svecenici;

  List<SvecenikModel> get svecenici {
    return [..._svecenici];
  }

  Future<void> fetchAndSetSvecenici() async {
    var url = GlobalVar.apiUrl+'user/getallusers?role=svecenik';
    var response = await http.get(url);

    var extractData = json.decode(response.body);
    List<SvecenikModel> sveceniciToAdd = new List<SvecenikModel>();

    extractData.forEach((svecenik) {
      print(svecenik);
      sveceniciToAdd.add(SvecenikModel(
        id: svecenik['id'],
        ime: svecenik['ime'],
        prezime: svecenik['prezime'],
        email: svecenik['email'],
        username: svecenik['username']
      ));
    });
    _svecenici = sveceniciToAdd;

    notifyListeners();
  }

}