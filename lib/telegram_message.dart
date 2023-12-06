class TelegramMessage {
  int date = 0;
  String from = '';
  String fromId = '';
  String text = '';
  bool received = true;

  Map<String, dynamic> toJson() => {
        "date": date,
        "from": from,
        "fromId": fromId,
        "text": text,
        "received": received,
      };

  @override
  String toString() => '$date|$from|$fromId|$text|$received';
}
