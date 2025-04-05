import 'dart:convert';

import 'package:move_to_signal/model/whats_app_reaction.dart';

class WhatsAppMessage {
  int timestamp = 0;
  int receivedTimestamp = 0;
  int receiptServerTimestamp = 0;
  int? contactId;
  bool fromMe = false;
  int read = 0;
  int type = 0;
  String text = '';
  List<WhatsAppReaction> reactions = [];

  WhatsAppMessage fromDynamic(dynamic data) {
    final whatsAppMessage = WhatsAppMessage();
    whatsAppMessage.timestamp = data['timestamp'] ?? 0;
    whatsAppMessage.receivedTimestamp = data['receivedTimestamp'] ?? 0;
    whatsAppMessage.receiptServerTimestamp =
        data['receiptServerTimestamp'] ?? 0;
    whatsAppMessage.contactId = data['contactId'];
    whatsAppMessage.fromMe = data['fromMe'] ?? false;
    whatsAppMessage.read = data['read'] ?? 0;
    whatsAppMessage.type = data['type'] ?? 0;
    whatsAppMessage.text = data['text'] ?? '';

    for (var reaction in data['reactions'] ?? []) {
      whatsAppMessage.reactions.add(WhatsAppReaction().fromDynamic(reaction));
    }

    return whatsAppMessage;
  }

  @override
  String toString() => {
        '"timestamp"': timestamp,
        '"receivedTimestamp"': receivedTimestamp,
        '"receiptServerTimestamp"': receiptServerTimestamp,
        '"contactId"': contactId,
        '"fromMe"': fromMe,
        '"read"': read,
        '"type"': type,
        '"text"': jsonEncode(text),
        '"reactions"': reactions,
      }.toString();
}
