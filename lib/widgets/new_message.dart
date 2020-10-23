import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/poruke.dart';

class NewMessage extends StatefulWidget {
  final String senderId;
  final String sender;
  final String documentId;


  NewMessage(this.senderId, this.sender, this.documentId);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();

  Future<void> _sendMessage() async {
    var documentId = widget.documentId;

    if(widget.senderId == null) {
      print('senderId is empty');
      return;
    }

    if(widget.documentId == null) {
      print('documentid is empty');
      return;
    }
    print('sending to '+ documentId);
    FocusScope.of(context).unfocus();
    
    Firestore.instance.collection('/chats/$documentId/messages').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'senderId': widget.senderId,
      'sender': widget.sender
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    print('new message');
    //print('widget documentId ' +widget.documentId);
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