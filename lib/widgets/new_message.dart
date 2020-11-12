import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/poruke.dart';

import '../notifikacije.dart';

class NewMessage extends StatefulWidget {
  final String senderId;
  final String sender;
  final String documentId;
  final String primaocId;
  final List<String> primaocListId;
  final String collectionName;

  NewMessage({this.collectionName, this.senderId, this.sender, this.documentId, this.primaocId, this.primaocListId});

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();

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
      Notifikacije.sendNotificationForOneUser(userId: widget.primaocId, content: _enteredMessage);
    }
    else {
      print('sent to many');
      Notifikacije.sendNotificationForManyUsers(userId: widget.primaocListId, content: _enteredMessage);
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
            controller: _controller,
            decoration: InputDecoration(labelText: 'Napiši poruku...'),
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
