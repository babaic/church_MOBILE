import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obredi.dart';
import 'package:saborna_crkva/providers/svecenik.dart';
import 'package:saborna_crkva/widgets/message_bubble.dart';
import 'package:saborna_crkva/widgets/new_message.dart';

class ObredKonverzacijaScreen extends StatefulWidget {
  static const routeName = '/obred-konverzacija';

  @override
  _ObredKonverzacijaScreenState createState() => _ObredKonverzacijaScreenState();
}

class _ObredKonverzacijaScreenState extends State<ObredKonverzacijaScreen> {
  String documentId;
  bool _isInit = true;
  List<String> userids = [];

  // @override
  // void initState() {
  //   print('initState');
  //   Provider.of<Svecenik>(context, listen: false)
  //       .fetchAndSetSvecenici()
  //       .then((value) {
  //         Provider.of<Svecenik>(context, listen:false).svecenici.forEach((svecenik) {
  //           userids.add(svecenik.id.toString());
  //           //print(svecenik.id);
  //         });
  //       });
  //   print(userids);
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    var userData = Provider.of<Auth>(context, listen: false).user;
    if (_isInit){
    Provider.of<Svecenik>(context, listen: false)
        .fetchAndSetSvecenici()
        .then((value) {
          Provider.of<Svecenik>(context, listen:false).svecenici.forEach((svecenik) {
            userids.add(svecenik.id.toString());
          });
        });
    //print(userids); 
    }
    userids.removeWhere((element) => element == userData.id.toString());
    _isInit = false; //VERY IMPORTANT TO SET TO FALSE
    super.didChangeDependencies();
  }

  String createDocument(int obredId) {
    var docRef = Firestore.instance.collection('obredi').document();
    var userData = Provider.of<Auth>(context, listen: false).user;

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(docRef, {
        'inicijatorId': userData.id,
        'inicijatorName': userData.username,
        'obredId': obredId.toString()
      });
    });
    print('creating document... ' + docRef.documentID);
    return docRef.documentID;
  }
  
  @override
  Widget build(BuildContext context) {
    print('obred konverzacija build');
    final user = Provider.of<Auth>(context, listen: false).user;
    var args = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
      appBar: AppBar(
        title: Text('Konverzacija'),
        actions: [
          if(user.role == 'Svecenik')
          FlatButton.icon(onPressed: () {
            setState(() {
              Provider.of<Obredi>(context, listen: false).updateStatus(args, 'Zavrseno');
            });
          }, icon: Icon(Icons.lock), label: Text('Završi'), textColor: Colors.white,)
        ],
      ),
      body: FutureBuilder(
        future: Firestore.instance
                .collection('obredi')
                .where("obredId", isEqualTo: args.toString())
                .getDocuments()
                .then((value) {
                  //first check if document exist
                  if (value.documents.length == 0) {
                    documentId = createDocument(args);
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
          if(futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)),
            );
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: Firestore.instance
                        .collection('/obredi/$documentId/messages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                  builder: (ctx, streamSnapshot) {
                    if(streamSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)));
                    }
                    final documents = streamSnapshot.data.documents;
                    return ListView.builder(
                      reverse: true,
                      itemCount: documents.length,
                      itemBuilder: (ctx, index) => MessageBubble(
                        message: documents[index]['text'],
                        username: documents[index]['sender'],
                        isMe: documents[index]['senderId'] == user.id.toString() ? true : false,
                      )
                    );
                  },
                ),
              ),
              Provider.of<Obredi>(context, listen: false).isZavrsen(args) ? Center(child: Container(height: 30, child: Text('Konverzacija je završena.')),) : NewMessage(collectionName: 'obredi', senderId: user.id.toString(), sender: user.username, documentId: documentId, primaocId: null, primaocListId: userids, obredId: args,),
            ],
          );
        }
      ),
    );
  }
}