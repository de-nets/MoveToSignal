import 'dart:convert';

class WhatsAppReaction {
  String? reaction;
  bool? fromMe;
  int? sendTimestamp;
  int? receivedTimestamp;

  @override
  String toString() => {
        '"reaction"': jsonEncode(reaction),
        '"fromMe"': fromMe,
        '"sendTimestamp"': sendTimestamp,
        '"receivedTimestamp"': receivedTimestamp,
      }.toString();
}
