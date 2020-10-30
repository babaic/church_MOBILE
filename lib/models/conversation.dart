import 'package:provider/provider.dart';

class Conversation {
  final String sender;
  final String svecenikId;
  final String lastMessage;
  final String otherUser;
  final List<String> ucesnici;

  Conversation(this.sender, this.svecenikId, this.lastMessage, this.otherUser, this.ucesnici);
}