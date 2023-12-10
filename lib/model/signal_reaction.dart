import 'dart:convert';

class SignalReaction {
  int? authorId;
  String? reaction;
  bool? fromMe;
  int? sendTimestamp;
  int? receivedTimestamp;

  @override
  String toString() => {
        '"authorId"': authorId,
        '"reaction"': jsonEncode(reaction),
        '"fromMe"': fromMe,
        '"sendTimestamp"': sendTimestamp,
        '"receivedTimestamp"': receivedTimestamp,
      }.toString();
}
