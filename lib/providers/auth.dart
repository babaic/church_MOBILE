import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:saborna_crkva/globalVar.dart';
import 'package:saborna_crkva/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  //NOTICE!
  //Think about adding static var for user data
  String _token;
  int _userId;
  String _role;

  User _user;

  bool get isAuth {
    return _token != null;
  }

  User get user {
    return _user;
  }

  String get token {
    return _token;
  }


  Future<void> setUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    var user = new User(
      id: extractedData['userId'],
      username: extractedData['username'],
      role: extractedData['role']
    );
    _user = user;

    //OneSignal
    //_handleGetPermissionSubscriptionState();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    await setUserData();
    notifyListeners();
    return true;
  }

  Future<void> _authenticate(
      {String email,
      String password,
      String ime,
      String prezime,
      String urlSegment}) async {
    final url = GlobalVar.apiUrl + 'auth/$urlSegment';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (urlSegment == 'login') {
      final response = await http.post(url,
          headers: GlobalVar.headers,
          body: json.encode({'email': email, 'password': password}));
      if (response.statusCode == 401) {
        throw ('Pogrešno korisničko ime ili lozinka');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final userData = json.encode({
        'userId': data['id'],
        'username': data['username'],
        'role': data['role'],
        'token': data['token'],
      });
      await prefs.setString('userData', userData);
      await setUserData();
      _token = data['token'];
      _handleGetPermissionSubscriptionState();
    }
    else {
      final response = await http.post(url,
        headers: GlobalVar.headers,
        body: json.encode({'email': email, 'password': password, 'ime': ime, 'prezime': prezime}));
      if(response.statusCode != 200) {
        throw(response.body);
      }
      await login(email, password);
      //await prefs.setString('userData', userData);
      //await setUserData();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authenticate(email: email, password: password, urlSegment: 'login');
  }
  Future<void> register(String email, String password, String ime, String prezime) async {
    await _authenticate(email: email, password: password, ime: ime, prezime: prezime, urlSegment: 'register');
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    _token = null;
    _userId = null;
    deleteDeviceFromFirestore();
    notifyListeners();
  }

  void _handleGetPermissionSubscriptionState() {
    print("Getting permissionSubscriptionState");
    OneSignal.shared.getPermissionSubscriptionState().then((status) {
      //print(status.subscriptionStatus.userId);

      var docRef = Firestore.instance
          .collection('notifications')
          .document(_user.id.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {});
      });

      var docId = docRef.documentID;
      Firestore.instance
          .collection('/notifications/$docId/device')
          .add({'deviceId': status.subscriptionStatus.userId});
    });
  }

  void deleteDeviceFromFirestore() {
    var userId = _user.id;
    OneSignal.shared.getPermissionSubscriptionState().then((status) {
      Firestore.instance
          .collection('/notifications/$userId/device')
          .where('deviceId', isEqualTo: status.subscriptionStatus.userId)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          element.reference.delete();
        });
      });
    });
  }
}
