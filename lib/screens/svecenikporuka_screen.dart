import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/poruke.dart';

import 'package:saborna_crkva/widgets/new_message.dart';
import 'package:saborna_crkva/widgets/message_bubble.dart';

class SvecenikPorukaScreen extends StatefulWidget {
  static const routeName = '/svecenik-poruka';

  @override
  _SvecenikPorukaScreenState createState() => _SvecenikPorukaScreenState();
}

class _SvecenikPorukaScreenState extends State<SvecenikPorukaScreen> {
  var svecenikImePrezime;
  String primaocId;
  String documentId;
  bool futureFinished = false;
  Map<String, int> sortedIds;
  List<String> ucesnici;

  Map<String, String> userIds(int id1, int id2) {
    Map<String, String> sorted = new Map();
  
    if(id1 < id2) {
      sorted["id1"] = id1.toString();
      sorted["id2"] = id2.toString();
    }
    else {
      sorted["id1"] = id2.toString();
      sorted["id2"] = id1.toString();
    }
    
    return sorted;
}

  String createDocument(String userkey1, String userkey2) {
    var docRef = Firestore.instance.collection('chats').document();
    var userData = Provider.of<Auth>(context, listen: false).user;

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(docRef, {
        'userkey': [userkey1, userkey2],
        'svecenikId': primaocId,
        'ucesnici': [svecenikImePrezime, userData.username]
      });
    });
    print('creating document... ' + docRef.documentID);
    return docRef.documentID;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false).user;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    svecenikImePrezime = args['imePrezime'];
    primaocId = args['svecenikId'];
    ucesnici = args['ucesnici'];

    if(primaocId == user.id.toString()) {
      primaocId = ucesnici[0] == primaocId ? ucesnici[1] : ucesnici[0];
    }

    var sorted = userIds(user.id, int.parse(primaocId));

    return Scaffold(
        appBar: AppBar(
          title: Text('Napiši poruku ' + svecenikImePrezime),
          actions: [],
        ),
        body: FutureBuilder(
            future: Firestore.instance
                .collection('chats')
                .where("userkey", isEqualTo: [sorted['id1'], sorted['id2']])
                .getDocuments()
                .then((value) {
                  //first check if document exist
                  if (value.documents.length == 0) {
                    documentId = createDocument(sorted['id1'], sorted['id2']);
                    print('document created... ' + documentId);
                  } else {
                    //else document exist
                    value.documents.forEach((element) {
                      print('document exist... ' + element.documentID);
                      documentId = element.documentID;
                    });
                  }
                }),
            builder: (ctx, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)),
                );
              }
              return Column(
                children: [
                  Expanded(child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('/chats/$documentId/messages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    //Firestore.instance.collection('chats').snapshots(),
                    builder: (ctx, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)));
                      }
                      final documents = streamSnapshot.data.documents;
                      
                      return ListView.builder(
                          reverse: true,
                          itemCount: documents.length,
                          itemBuilder: (ctx, index) => MessageBubble(
                                message: documents[index]['text'],
                                username: documents[index]['sender'],
                                isMe: documents[index]['senderId'] ==
                                        user.id.toString()
                                    ? true
                                    : false,
                              ));
                    },
                  )),
                  NewMessage(collectionName: 'chats', senderId: user.id.toString(), sender: user.username, documentId: documentId, primaocId: primaocId, primaocListId: null),
                ],
              );
            }));
  }
}
