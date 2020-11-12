import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../globalVar.dart';
import 'auth.dart';

class ObredKategorija {
  final int id;
  final String naziv;
  ObredKategorija({this.id, this.naziv});
}

class Obred {
  final int id;
  final String naziv;
  final String imePrezime;
  final String datum;
  String status;

  Obred({this.id, this.naziv, this.imePrezime, this.datum, this.status});
}

class Obredi with ChangeNotifier {
  List<ObredKategorija> obrediKategorije = [];
  List<Obred> _obredi = [];

  List<Obred> get obredi {
    return [..._obredi];
  }

  Future<void> fetchAndSetObredKategorije() async {
    var url = GlobalVar.apiUrl+'obredi/getobredikategorije';
    var response = await http.get(url);

    var extractData = json.decode(response.body);
    List<ObredKategorija> kategorijeToAdd = new List<ObredKategorija>();

    extractData.forEach((kategorija) {
      //print(kategorija);
      kategorijeToAdd.add(ObredKategorija(
       id: kategorija['id'],
       naziv: kategorija['naziv']
      ));
    });
    obrediKategorije = kategorijeToAdd;
    notifyListeners();
  }

  Future<int> zakaziObred(int userId, int obredKategorijaId) async {
    var url = GlobalVar.apiUrl+'obredi/addobred';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    var response = await http.post(url, headers: headers, body: json.encode({
      'userId': userId,
      'obredKategorijaId': obredKategorijaId
    }));

    var extractData = json.decode(response.body);

    return extractData['obredId'];

  }

  Future<void> getObredi(int userid) async {
    print('getObredi');
    var url = GlobalVar.apiUrl+'obredi/getobredi';
    if(userid != null) {
      url+='?userid=$userid';
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    var response = await http.get(url, headers: headers);
    var extractedResult = json.decode(response.body) as List<dynamic>;
    List<Obred> obrediToAdd = new List<Obred>();
    extractedResult.forEach((obred) {
      obrediToAdd.add(Obred(
        id: obred['id'],
        naziv: obred['kategorija'],
        imePrezime: obred['imePrezime'],
        datum: obred['datum'],
        status: obred['status']
      ));
    });
    _obredi = obrediToAdd;
    notifyListeners();
  }

  Future<void> updateStatus(int obredId, String status) async {
    final obredIndex = _obredi.indexWhere((obred) => obred.id == obredId);
    var url = GlobalVar.apiUrl+'obredi/updatestatus/$obredId';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    var response = http.put(url, headers: headers, body: json.encode({
      'status': status
    }));
    _obredi[obredIndex].status = status;

    notifyListeners();
  }

  bool isZavrsen(int obredId) {
    var obredIndex = _obredi.indexWhere((element) => element.id == obredId);
    print(_obredi[obredIndex].status == 'Zavrseno');
    return _obredi[obredIndex].status == 'Zavrseno';
  }

}