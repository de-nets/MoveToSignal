class SignalThread {
  int? threadId;
  int date = 0;
  String snippet = '';
  int snippetType = 10485780;
  int lastSeen = 0;

  Map<String, dynamic> toJson() => {
        "_id": threadId,
        "date": date,
        "snippet": snippet,
        "snippetType": snippetType,
        "lastSeen": lastSeen,
      };

  @override
  String toString() => '$threadId|$date|$snippet|$snippetType|$lastSeen';
}
