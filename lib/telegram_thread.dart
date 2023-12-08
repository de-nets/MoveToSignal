import 'package:move_to_signal/telegram_message.dart';

class TelegramThread {
  String name = '';
  String fromId = '';
  String phoneNumber = '';
  List<TelegramMessage> messages = [];

  Map<String, dynamic> toJson() => {
        "name": name,
        "fromId": fromId,
        "phoneNumber": phoneNumber,
        "messages": messages,
      };

  @override
  String toString() => '$name|$fromId|$phoneNumber|$messages';
}
