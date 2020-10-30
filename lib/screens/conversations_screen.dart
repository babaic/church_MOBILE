import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/models/conversation.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/widgets/conversation_bubble.dart';

import 'svecenikporuka_screen.dart';

class ConversationsScreen extends StatelessWidget {
  static const routeName = '/poruke';
  List<Conversation> conversations = new List<Conversation>();
  List<Map<String, String>> ucesnici;

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<Auth>(context, listen: false).user;
    return Scaffold(
        appBar: AppBar(
          title: Text('Poruke'),
        ),
        body: FutureBuilder(
          future: Firestore.instance
                      .collection('chats')
                      .where("userkey", arrayContains: userData.id.toString())
                      .getDocuments()
                      .then((value) {
                    value.documents.forEach((element) {
                      print(element.documentID);
                      print(element.data['lastMessage']);
                      var otherUser;
                      if(element.data['ucesnici'][0] == userData.username) {
                        otherUser = element.data['ucesnici'][1];
                      }
                      else {
                        otherUser = element.data['ucesnici'][0];
                      }
                      if(element.data.length >=5) {
                        print(element.data['userkey'][0]);
                        List<String> ids = new List<String>();
                        ids.add(element.data['userkey'][0]);
                        ids.add(element.data['userkey'][1]);
                        conversations.add(Conversation(element.data['sender'], element.data['svecenikId'], element.data['lastMessage'], otherUser, ids));
                      }
                    });
                  }),
          builder: (ctx, futureSnapshot) {
            if(futureSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            }
            return ListView.builder(itemCount: conversations.length, itemBuilder: (ctx, index) => ConversationBubble(conversations[index].sender, conversations[index].svecenikId, conversations[index].lastMessage, conversations[index].otherUser, conversations[index].ucesnici));
        })
        );
  }
}
