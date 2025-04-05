import 'dart:convert';

import 'package:move_to_signal/model/whats_app_message.dart';
import 'package:move_to_signal/model/whats_app_participant.dart';

class WhatsAppThread {
  int id = 0;
  String name = '';
  bool isGroup = false;
  String fromId = '';
  String phoneNumber = '';
  int createdTimestamp = 0;
  List<WhatsAppParticipant> participants = [];
  List<WhatsAppMessage> messages = [];

  WhatsAppThread fromDynamic(dynamic data) {
    final whatsAppThread = WhatsAppThread();
    whatsAppThread.id = data['id'] ?? '';
    whatsAppThread.name = data['name'] ?? '';
    whatsAppThread.isGroup = data['isGroup'] ?? false;
    whatsAppThread.phoneNumber = data['phoneNumber'] ?? '';
    whatsAppThread.createdTimestamp = data['createdTimestamp'] ?? 0;

    for (var participant in data['participants'] ?? []) {
      whatsAppThread.participants
          .add(WhatsAppParticipant().fromDynamic(participant));
    }
    for (var message in data['messages'] ?? []) {
      whatsAppThread.messages.add(WhatsAppMessage().fromDynamic(message));
    }
    return whatsAppThread;
  }

  @override
  String toString() => {
        '"id"': id,
        '"name"': jsonEncode(name),
        '"fromId"': jsonEncode(fromId),
        '"isGroup"': isGroup,
        '"phoneNumber"': jsonEncode(phoneNumber),
        '"createdTimestamp"': createdTimestamp,
        '"participants"': participants,
        '"messages"': messages,
      }.toString();
}
