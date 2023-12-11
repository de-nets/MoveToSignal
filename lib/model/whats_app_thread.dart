import 'package:move_to_signal/model/whats_app_message.dart';

class WhatsAppThread {
  String id = '';
  String name = '';
  String fromId = '';
  String phoneNumber = '';
  List<WhatsAppMessage> messages = [];

  @override
  String toString() => {
        "id": id,
        "name": name,
        "fromId": fromId,
        "phoneNumber": phoneNumber,
        "messages": messages,
      }.toString();
}
