import 'dart:convert';

class WhatsAppReaction {
  String? reaction;
  int? contactId;
  bool fromMe = false;
  int? sendTimestamp;
  int? receivedTimestamp;

  WhatsAppReaction fromDynamic(dynamic data) {
    final whatsAppReaction = WhatsAppReaction();
    whatsAppReaction.reaction = data['reaction'];
    whatsAppReaction.contactId = data['contactId'];
    whatsAppReaction.fromMe = data['fromMe'] ?? false;
    whatsAppReaction.sendTimestamp = data['sendTimestamp'];
    whatsAppReaction.receivedTimestamp = data['receivedTimestamp'];

    return whatsAppReaction;
  }

  @override
  String toString() => {
        '"reaction"': jsonEncode(reaction),
        '"contactId"': contactId,
        '"fromMe"': fromMe,
        '"sendTimestamp"': sendTimestamp,
        '"receivedTimestamp"': receivedTimestamp,
      }.toString();
}
