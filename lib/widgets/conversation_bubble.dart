import 'package:flutter/material.dart';
import 'package:saborna_crkva/models/conversation.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';

class ConversationBubble extends StatelessWidget {
  final String lastMessageBy;
  final String svecenikid;
  final String lastMessage;
  final String otherUser;
  List<String> ucesnici;

  ConversationBubble(this.lastMessageBy, this.svecenikid, this.lastMessage, this.otherUser, this.ucesnici);

  String getInitials(String name) {
  List<String> names = name.split(" ");
  String initials = "";
  int numWords = 2;
  
  if(numWords < names.length) {
    numWords = names.length;
  }
  for(var i = 0; i < numWords; i++){
    initials += '${names[i][0]}';
  }
  return initials;
}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(getInitials(lastMessageBy)),
      ),
      title: Text(
        lastMessageBy,
        textScaleFactor: 1.0,
      ),
      subtitle: Text(
        lastMessage,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => Navigator.of(context).pushNamed(
          SvecenikPorukaScreen.routeName,
          arguments: {'imePrezime': otherUser, 'svecenikId': svecenikid, 'ucesnici': ucesnici}),
    );
  }
}
