import 'dart:convert';

class WhatsAppMessage {
  int timestamp = 0;
  int receivedTimestamp = 0;
  int receiptServerTimestamp = 0;
  bool fromMe = true;
  int read = 0;
  String text = '';

  Map<String, dynamic> toJson() => {
        '"timestamp"': timestamp,
        '"receivedTimestamp"': receivedTimestamp,
        '"receiptServerTimestamp"': receiptServerTimestamp,
        '"fromMe"': fromMe,
        '"read"': read,
        '"text"': jsonEncode(text),
      };

  @override
  String toString() =>
      '$timestamp|$receivedTimestamp|$receiptServerTimestamp|$fromMe|$read|$text';
}
