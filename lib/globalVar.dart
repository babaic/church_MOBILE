class GlobalVar {
  static const apiUrl = 'http://192.168.43.198:45455/api/';
  static const apiUri = '192.168.43.198:45455';
  static Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
  static Map<String, String> headersToken (String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
  }

  

  //image urls
  static const notificationImg = 'https://i.imgur.com/HjZLnil.png';
}