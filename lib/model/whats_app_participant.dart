import 'dart:convert';

class WhatsAppParticipant {
  int id = 0;
  String phoneNumber = '';
  int rank = 0;

  WhatsAppParticipant fromDynamic(dynamic data) {
    final whatsAppParticipant = WhatsAppParticipant();
    whatsAppParticipant.id = data['id'] ?? 0;
    whatsAppParticipant.phoneNumber = data['phoneNumber'] ?? '';
    whatsAppParticipant.rank = data['rank'] ?? 0;

    return whatsAppParticipant;
  }

  @override
  String toString() => {
        '"id"': id,
        '"phoneNumber"': jsonEncode(phoneNumber),
        '"rank"': rank,
      }.toString();
}
