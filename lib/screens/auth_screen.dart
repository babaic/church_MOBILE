import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';

enum AuthMode { Login, Signup }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'Email': '',
    'Password': '',
    'Ime': '',
    'Prezime': ''
  };
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();

  Future<void> submitForm(AuthMode authMode) async {
    var authProvider = Provider.of<Auth>(context, listen: false);

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    if (authMode == AuthMode.Signup) {
      try {
        await authProvider.register(_authData['Email'], _authData['Password'],
          _authData['ime'], _authData['prezime']);
      }
      catch(error) {
        _showErrorDialog(error);
      }
      
    }

    if (authMode == AuthMode.Login) {
      try {
        await authProvider.login(_authData['Email'], _authData['Password']);
      } catch (error) {
        _showErrorDialog(error);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Greška!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'assets/images/paper.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Container(
                    alignment: Alignment.bottomRight,
                    height: _authMode == AuthMode.Signup ? 100 : 150,
                    width: _authMode == AuthMode.Signup ? 100 : 150,
                    child: Image.asset(
                      'assets/images/crkva.png',
                      fit: BoxFit.cover,
                    )),
                Container(
                  child: Text(
                    'Саборна црква Свете Тројице',
                    style: TextStyle(
                        fontFamily: 'RuslanDisplay-Regular', fontSize: 20),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 100),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0))),
                    padding: EdgeInsets.all(10),
                    width: 300,
                    //height: 200,
                    //color: Colors.white70,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'E-Mail'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return 'Unesite ispravan email';
                              }
                            },
                            onSaved: (value) {
                              _authData['Email'] = value;
                            },
                          ),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Ime'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Unesite Vaše ime';
                                }
                              },
                              onSaved: (value) => _authData['ime'] = value,
                            ),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Prezime'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Unesite Vaše prezime';
                                }
                              },
                              onSaved: (value) => _authData['prezime'] = value,
                            ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(labelText: 'Lozinka'),
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Unesite lozinku';
                              }
                            },
                            onSaved: (value) {
                              _authData['Password'] = value;
                            },
                          ),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              enabled: _authMode == AuthMode.Signup,
                              decoration:
                                  InputDecoration(labelText: 'Potvrdi lozinku'),
                              obscureText: true,
                              validator: _authMode == AuthMode.Signup
                                  ? (value) {
                                      if (value != _passwordController.text) {
                                        return 'Lozinke se ne podudaraju!';
                                      }
                                    }
                                  : null,
                            ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 10),
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorLight,
                              child: Text(_authMode == AuthMode.Login
                                  ? 'Prijava'
                                  : 'Registracija'),
                              onPressed: () => submitForm(_authMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        _authMode == AuthMode.Login
                            ? 'Registruj se'
                            : 'Prijavi se',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onPressed: () {
                        setState(() {
                          _authMode = _authMode == AuthMode.Login
                              ? AuthMode.Signup
                              : AuthMode.Login;
                        });
                      },
                    ),
                    padding: EdgeInsets.only(top: 40),
                  ),
                ],
              ),
            ),
            Positioned(child: Text('❥ FIT Mostar', style: TextStyle(color: Colors.black, fontSize: 10),), bottom: 10,)
          ],
        ),
      ),
    );
  }
}
