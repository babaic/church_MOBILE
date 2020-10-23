import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saborna_crkva/globalVar.dart';
import 'package:saborna_crkva/models/poruka.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Poruke with ChangeNotifier {
  List<Poruka> poruke;

  Future<String> get myId async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final String myid = extractedData['userId'].toString();
    return myid;
  }


  Future<void> posaljiPoruku(String poruka, String primaocId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final String myid = extractedData['userId'].toString();

    final url = GlobalVar.apiUrl+'user/sendmessage';

    var headers = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};

    final response = await http.post(url, headers: headers, body: json.encode({
      'senderId': myid,
      'receiverId': primaocId,
      'text': poruka
    }));
  }

  Future<void> getPoruke() async {
   
    
     notifyListeners();
  }


}