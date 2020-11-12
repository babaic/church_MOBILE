import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:saborna_crkva/models/donacija.dart';

import '../globalVar.dart';

class Donacije with ChangeNotifier {
  var dummy = 'test';
  List<DonacijaToDisplay> _donacije = [];

  List<DonacijaToDisplay> get donacije {
    return [..._donacije];
  }

  Future<void> doniraj(int iznos, String desc, String mjesec, String godina,
      String brKartice, String cvv, int userid) async {
    var url = GlobalVar.apiUrl + 'uplata/pay';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    final response = await http.post(url,
          headers: headers,
          body: json.encode({
            'BrojKartice': brKartice,
            'Mjesec': mjesec,
            'Godina': godina,
            'CVV': cvv,
            'Amount': iznos,
            'Desc': desc,
            'UserId': userid
          }));
      if(response.statusCode != 200) {
        throw(response.body);
      }
  }

  Future<void> fetchAndSetDonacije({int id = 0}) async {
    var url = GlobalVar.apiUrl + 'uplata/getdonations';
    if(id != null) {
      url+= '?userid=$id';
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    final response = await http.get(url, headers: headers);
    final extractedData = json.decode(response.body) as List<dynamic>;
    List<DonacijaToDisplay> donacijeToAdd = new List<DonacijaToDisplay>();
    extractedData.forEach((element) {
      donacijeToAdd.add(DonacijaToDisplay(
        id: element['id'],
        datum: element['datum'],
        iznos: element['iznos'],
        poruka: element['poruka'],
        imePrezime: element['imePrezime'],
        userId: element['userId']
      ));
    });
    _donacije = donacijeToAdd;
    
    notifyListeners();
  }
}
