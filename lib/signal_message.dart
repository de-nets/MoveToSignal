class SignalMessage {
  int messageDateTime = 0;
  int? dateSent;
  int? dateReceived;
  int? dateServer;
  int threadId = 0;
  int? fromRecipientId;
  int? fromDeviceId;
  int toRecipientId = 1;
  int type = 10485780;
  String body = '';
  int read = 1;
  int mType = 132;
  int? st = 1;
  int receiptTimestamp = -1;
  int hasDeliveryReceipt = 0;
  int hasReadReceipt = 0;
  int unidentified = 1;
  int reactionsLastSeen = -1;
  int notifiedTimestamp = 0;

  Map<String, dynamic> toJson() => {
        "dateSent": dateSent,
        "dateReceived": dateReceived,
        "dateServer": dateServer,
        "threadId": threadId,
        "fromRecipientId": fromRecipientId,
        "fromDeviceId": fromDeviceId,
        "toRecipientId": toRecipientId,
        "type": type,
        "body": body,
        "read": read,
        "mType": mType,
        "st": st,
        "receiptTimestamp": receiptTimestamp,
        "hasDeliveryReceipt": hasDeliveryReceipt,
        "hasReadReceipt": hasReadReceipt,
        "unidentified": unidentified,
        "reactionsLastSeen": reactionsLastSeen,
        "notifiedTimestamp": notifiedTimestamp,
      };

  @override
  String toString() =>
      '$dateSent|$dateReceived|$dateServer|$threadId|$fromRecipientId|$fromDeviceId|$toRecipientId|$type|$body|$read|$mType|$st|$receiptTimestamp|$hasDeliveryReceipt|$hasReadReceipt|$unidentified|$reactionsLastSeen|$notifiedTimestamp';

  void setReceived() {
    dateSent = messageDateTime;
    dateServer = dateSent! + 500;
    dateReceived = dateServer! + 1000;
    notifiedTimestamp = dateReceived! + 500;
    reactionsLastSeen = notifiedTimestamp + 5000;
  }

  void setSend() {
    dateSent = messageDateTime;
    dateReceived = dateSent! + 1000;
    dateServer = -1;
    fromDeviceId = 1;
    type = 10485783;
    mType = 128;
    st = null;
    receiptTimestamp = dateReceived! + 1000;
    hasDeliveryReceipt = 1;
    hasReadReceipt = 1;
  }
}
