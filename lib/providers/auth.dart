import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:saborna_crkva/globalVar.dart';
import 'package:saborna_crkva/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
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

  Future<void> setUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    var user = new User(
      id: extractedData['userId'],
      username: extractedData['username'],
      role: extractedData['role']
    );
    _user = user;
  }


  Future<bool> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) {
      _token = null;
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedData['token'];
    
    await setUserData();
    
    notifyListeners();
    
    return true;
  }


  Future<void> register(String email, String password) async {
    final url = GlobalVar.apiUrl+'auth/register';
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'email': email, 'password': password}));
    print(response.body);
  }

  Future<void> login(String email, String password) async {
    print('login');
    final url = GlobalVar.apiUrl+'auth/login';
    Map<String, String> headers = {
    'Content-Type': 'application/json;charset=UTF-8',
    'Charset': 'utf-8'
};
    final response = await http.post(url,
        headers: headers,
        body: json.encode({'email': email, 'password': password}));

    //print(response.statusCode);
    // if(response.statusCode == 401) {
    //   throw HttpException('Pogrešno korisničko ime ili lozinka');
    // }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    print(data);

    final userData = json.encode({
      'userId': data['id'],
      'username': data['username'],
      'role': data['role'],
      'token': data['token'],
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', userData);

    await setUserData();
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    _token = null;

    notifyListeners();
  }


}