import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/models/donacija.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/donacije.dart';

import 'donacije_screen.dart';

enum PageStep { IznosPoruka, Kartica, SuccessPage }

class DonirajScreen extends StatefulWidget {
  static const routeName = '/doniraj';

  @override
  _DonirajScreenState createState() => _DonirajScreenState();
}

class _DonirajScreenState extends State<DonirajScreen> {
  PageStep pageStep = PageStep.IznosPoruka;
  Donacija donacija = new Donacija();

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

  Future<void> submitForm(
      {int iznos,
      String desc,
      String mjesec,
      String godina,
      String brKartice,
      String cvv}) async {
    setState(() {
      if (pageStep == PageStep.IznosPoruka) {
        pageStep = PageStep.Kartica;
      }
    });
    donacija.iznos = iznos == null ? donacija.iznos : iznos;
    donacija.desc = desc == null ? donacija.desc : desc;
    donacija.mjesec = mjesec == null ? donacija.mjesec : mjesec;
    donacija.godina = godina == null ? donacija.godina : godina;
    donacija.brKartice = brKartice == null ? donacija.brKartice : brKartice;
    donacija.cvv = cvv == null ? donacija.cvv : cvv;

    //this line represent Doniraj button
    if(donacija.cvv != null) {
      try {
       await Provider.of<Donacije>(context, listen: false).doniraj(donacija.iznos, donacija.desc, donacija.mjesec, donacija.godina, donacija.brKartice, donacija.cvv, Provider.of<Auth>(context, listen: false).user.id);
       setState(() {
        pageStep = PageStep.SuccessPage;
      });
      }
      catch (error) {
        _showErrorDialog(error);
      }
      
    }
  }

  Widget pageToShow() {
    if(pageStep == PageStep.IznosPoruka) {
      return IznosPorukaPage(submitForm);
    }
    else if(pageStep == PageStep.Kartica) {
      return KarticaPage(submitForm);
    }
    else {
      return SuccessPage();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doniraj'),
        actions: [
          FlatButton.icon(onPressed: () => Navigator.of(context).pushReplacementNamed(DonacijeScreen.routeName), icon: Icon(Icons.history), label: Text('Moje donacije'), textColor: Colors.white,)
        ],
      ),
      body: Container(
        width: double.infinity,
        child: pageToShow()
      ),
    );
  }
}

class IznosPorukaPage extends StatelessWidget {
  IznosPorukaPage(this.submitForm);
  final void Function(
      {int iznos,
      String desc,
      String mjesec,
      String godina,
      String brKartice,
      String cvv}) submitForm;

  final _formKey = GlobalKey<FormState>();

  int _iznos;
  var _desc;

  void _trySubmit() {
    var isValid = _formKey.currentState.validate();

    if (isValid) {
      _formKey.currentState.save();
      submitForm(iznos: _iznos, desc: _desc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Image.network(
                    'https://img.icons8.com/officel/80/000000/donate.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Unesi iznos donacije',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 200,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Unesite iznos donacije';
                    }
                    return null;
                  },
                  onSaved: (value) => _iznos = int.parse(value),
                  decoration:
                      InputDecoration(labelText: 'Iznos', suffix: Text('KM')),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                width: 200,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Poruka'),
                  onSaved: (value) => _desc = value,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Container(
                  width: 200,
                  padding: const EdgeInsets.only(top: 20.0),
                  child: FlatButton(
                    child: Text('Dalje'),
                    onPressed: _trySubmit,
                    color: Colors.green,
                    textColor: Colors.white,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class KarticaPage extends StatelessWidget {
  final void Function(
      {int iznos,
      String desc,
      String mjesec,
      String godina,
      String brKartice,
      String cvv}) submitForm;

  KarticaPage(this.submitForm);

  final _formKey = GlobalKey<FormState>();

  var _brKartica;
  var _mjesec;
  var _godina;
  var _cvv;

  void _trySubmit() {
    var isValid = _formKey.currentState.validate();

    if (isValid) {
      _formKey.currentState.save();
      submitForm(
          brKartice: _brKartica, mjesec: _mjesec, godina: _godina, cvv: _cvv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Image.network(
                    'https://img.icons8.com/cute-clipart/64/000000/bank-card-back-side.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Doniraj karticom',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 200,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty || value.length < 19) {
                      return 'Unesite broj kartice';
                    }
                    return null;
                  },
                  onSaved: (value) => _brKartica = value,
                  decoration: InputDecoration(labelText: 'Broj kartice'),
                  inputFormatters: [
                    MaskedTextInputFormatter(
                      mask: 'xxxx-xxxx-xxxx-xxxx',
                      separator: '-',
                    ),
                  ],
                ),
              ),
              Container(
                width: 280,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 90,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Unesite ispravan datum';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _mjesec = value.substring(0, 2);
                          _godina = value.substring(3, 5);
                        },
                        decoration: InputDecoration(labelText: 'Važi do'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskedTextInputFormatter2(
                            mask: 'xx/xx',
                            separator: '/',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Unesite CVV';
                          }
                          return null;
                        },
                        onSaved: (value) => _cvv = value,
                        decoration: InputDecoration(labelText: 'CVV'),
                        keyboardType: TextInputType.number,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  width: 200,
                  padding: const EdgeInsets.only(top: 20.0),
                  child: FlatButton(
                    child: Text('Doniraj '),
                    onPressed: _trySubmit,
                    color: Colors.green,
                    textColor: Colors.white,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://img.icons8.com/bubbles/200/000000/checkmark.png'),
          Text('Hvala Vam na donaciji', style: TextStyle(fontWeight: FontWeight.bold),),
        ],
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    @required this.mask,
    @required this.separator,
  }) {
    assert(mask != null);
    assert(separator != null);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

class MaskedTextInputFormatter2 extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter2({
    @required this.mask,
    @required this.separator,
  }) {
    assert(mask != null);
    assert(separator != null);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}
