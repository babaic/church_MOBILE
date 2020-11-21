import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_localization.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String LATINICA = 'bs';
const String CIRILICA = 'sr';


Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "bs";
  print(languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case LATINICA:
      return Locale(LATINICA, 'BA');
    case CIRILICA:
      return Locale(CIRILICA, "RS");
    default:
      return Locale(LATINICA, 'BA');
  }
}

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context).translate(key);
}