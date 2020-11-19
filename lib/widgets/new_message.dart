import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obredi.dart';
import 'package:saborna_crkva/providers/poruke.dart';
import 'package:saborna_crkva/providers/svecenik.dart';

import '../notifikacije.dart';

class NewMessage extends StatefulWidget {
  final String senderId;
  final String sender;
  final String documentId;
  final String primaocId;
  final List<String> primaocListId;
  final String collectionName;
  final int obredId;
  final bool isSpam;

  NewMessage({this.collectionName, this.senderId, this.sender, this.documentId, this.primaocId, this.primaocListId, this.obredId, this.isSpam});

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();

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

  Future<void> _sendMessage() async {
    var documentId = widget.documentId;
    var collectionName = widget.collectionName;

    if (widget.senderId == null) {
      print('senderId is empty');
      return;
    }

    if (widget.documentId == null) {
      print('documentid is empty');
      return;
    }
    FocusScope.of(context).unfocus();

    Firestore.instance.collection('/$collectionName/$documentId/messages').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'senderId': widget.senderId,
      'sender': widget.sender
    });

    //test try to update document -- add last message
    var docRef = Firestore.instance.collection("$collectionName").document(documentId);
    docRef
        .updateData({'lastMessage': _enteredMessage, 'sender': widget.sender});
    //end test
    _controller.clear();

    //SEND NOTIFICATION VIA ONESIGNAL
    if(widget.primaocId != null) {
      print('send to one');
      //Notifikacije.sendNotificationForOneUser(userId: widget.primaocId, content: _enteredMessage);
    }
    else {
      Notifikacije.sendNotificationForManyUsers(userId: widget.primaocListId, content: _enteredMessage);
      var svecenici = Provider.of<Svecenik>(context, listen: false).svecenici;

      for(var i = 0; i < svecenici.length; i++) {
        if(svecenici[i].id.toString() == widget.senderId) {
          //SVECENIK JE NAPISAO PORUKU PROMIJENI STATUS U ODGOVORENO
          await Provider.of<Obredi>(context, listen: false).updateStatus(widget.obredId, 'Odgovoreno');
          return;
        }
      }
      //KORISNIK JE NAPISAO PORUKU PROMIJENI STATUS U NIJE ODGOVORENO
      await Provider.of<Obredi>(context, listen: false).updateStatus(widget.obredId, 'Nije odgovoreno');
    
    }
    
  }

  void _handleSendNotification({String content, String userId}) async {
    List<String> devicesId = [];
    Firestore.instance
        .collection('/notifications/$userId/device')
        .getDocuments()
        .then((value) async {
      value.documents.forEach((element) {
        devicesId.add(element.data['deviceId']);
      });
      if (devicesId.length != 0) {
        var notification = OSCreateNotification(
          playerIds: devicesId,
          content: content,
          heading: "Imate novu poruku",
        );

        var response = await OneSignal.shared.postNotification(notification);
        print("Sent notification with response: $response");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                //enabled: false,
            controller: _controller,
            decoration: InputDecoration(labelText: 'Napiši poruku...'),
            onTap: ()=> widget.isSpam ? _showErrorDialog('Ne možete poslati više od 3 poruke uzastopno!') : null,
            readOnly: widget.isSpam ? true : false,
            onChanged: (value) {
              setState(() {
                _enteredMessage = value;
              });
            },
          )),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}
