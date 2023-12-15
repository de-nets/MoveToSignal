import 'dart:convert';

import 'package:move_to_signal/model/sms_message.dart';

class SmsThread {
  String name = '';
  String phoneNumber = '';
  List<SmsMessage> messages = [];

  @override
  String toString() => {
        '"name"': jsonEncode(name),
        '"phoneNumber"': jsonEncode(phoneNumber),
        '"messages"': messages,
      }.toString();
}
