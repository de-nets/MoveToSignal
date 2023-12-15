import 'dart:convert';

class SmsMessage {
  int date = 0;
  String from = '';
  String text = '';
  bool received = true;

  @override
  String toString() => {
        '"date"': date,
        '"from"': jsonEncode(from),
        '"text"': jsonEncode(text),
        '"received"': received,
      }.toString();
}
