import 'package:move_to_signal/model/whats_app_message.dart';

class WhatsAppThread {
  String id = '';
  String name = '';
  String fromId = '';
  String phoneNumber = '';
  List<WhatsAppMessage> messages = [];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fromId": fromId,
        "phoneNumber": phoneNumber,
        "messages": messages,
      };

  @override
  String toString() => '$id|$name|$fromId|$phoneNumber|$messages';
}
