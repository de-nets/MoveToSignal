import 'dart:convert';

import 'package:move_to_signal/model/whats_app_reaction.dart';

class WhatsAppMessage {
  int timestamp = 0;
  int receivedTimestamp = 0;
  int receiptServerTimestamp = 0;
  bool fromMe = true;
  int read = 0;
  String text = '';
  List<WhatsAppReaction> reactions = [];

  @override
  String toString() => {
        '"timestamp"': timestamp,
        '"receivedTimestamp"': receivedTimestamp,
        '"receiptServerTimestamp"': receiptServerTimestamp,
        '"fromMe"': fromMe,
        '"read"': read,
        '"text"': jsonEncode(text),
        '"reactions"': reactions,
      }.toString();
}
