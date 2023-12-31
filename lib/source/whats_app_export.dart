import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/import/signal.dart';
import 'package:move_to_signal/model/signal_message.dart';

class WhatsAppExport extends Signal {
  Directory? _whatsAppExports;

  @override
  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--whatsAppExports=')) {
        _whatsAppExports = Directory(argument.split('=').last);
      }
    }

    if (verbose) print('Run WhatsApp import');

    super.run(arguments);

    if (verbose) print('Check missing WhatsApp arguments');

    if (_whatsAppExports == null) {
      print('Missing argument --whatsAppExports');
      return;
    }

    if (verbose) print('Check WhatsApp Exports folder');

    if (!_whatsAppExports!.existsSync()) {
      print('--whatsappExports=${_whatsAppExports!.path} folder not found');
      return;
    }

    if (verbose) print('Get all WhatsApp Exports');

    signalBackupDecrypt();

    _whatsAppExports!.listSync().forEach((whatsappExport) {
      if (whatsappExport is File && whatsappExport.path.endsWith('.txt')) {
        _parseWhatsappExport(whatsappExport);
      }
    });

    signalImport();
  }

  int? _getMessageDate(String line) {
    if (line.length < 20 ||
        line.substring(10, 12) != ', ' ||
        line.substring(14, 15) != ':' ||
        line.substring(17, 20) != ' - ') {
      return null;
    }
    final date = line.substring(0, 10);
    final time = line.substring(12, 17);

    final dateTime = DateTime.tryParse(
        '${date.substring(6, 10)}-${date.substring(3, 5)}-${date.substring(0, 2)} $time:00.000');

    return dateTime?.millisecondsSinceEpoch;
  }

  void _parseWhatsappExport(File whatsappExport) {
    if (verbose) {
      print('Parse WhatsApp export: ${path.basename(whatsappExport.path)}');
    }

    var filename = path.basenameWithoutExtension(whatsappExport.path);
    var filenameParts = filename.split('-');

    if (filenameParts.length != 2) {
      print('File name format error ${whatsappExport.path}');
      return;
    }

    // Get contact date from filename
    final contactNumber = filenameParts[0];
    final contactName = filenameParts[1];

    final contactSignalId = signalGetRecipientID(contactNumber);
    if (contactSignalId == 0) {
      print(
          'No RecipientID was found for contact "$contactNumber" in Signal backup');
      return;
    }

    final contactSignalThreadId = signalGetThreadID(contactSignalId);
    if (contactSignalThreadId == 0) {
      print(
          'No ThreadId was found for contact "$contactNumber" in Signal backup');
      return;
    }

    // Init new SignalMessage
    var signalMessage = SignalMessage();

    // Read WhatsApp export file
    final messages = whatsappExport.readAsLinesSync();

    // Init addMessage as false to ignore invalid messages
    bool addMessage = false;

    for (final line in messages) {
      var messageDateTime = _getMessageDate(line);

      // Check if new message or line break
      if (messageDateTime == null) {
        // line break

        // Just add message and go to next line
        signalMessage.body = "${signalMessage.body}\n${line.trim()}";
        continue;
      }

      // Only push valid messages
      if (addMessage) {
        // Add last message
        signalAddMessage(signalMessage);
        signalMessage = SignalMessage();
      }

      signalMessage.messageDateTime = messageDateTime;

      // Check if line is long enough
      if (line.length < 20) {
        addMessage = false;
        signalMessage = SignalMessage();
        continue;
      }

      // Get sender and message part from line
      final senderAndMessage = line.substring(20);

      int splitPos = senderAndMessage.indexOf(":");

      // Check if sender and message part is valid
      if (splitPos == -1) {
        addMessage = false;
        signalMessage = SignalMessage();
        continue;
      }

      final senderName = senderAndMessage.substring(0, splitPos);
      signalMessage.body = senderAndMessage.substring(splitPos + 2);

      // Filter useless messages
      if (signalMessage.body == '<Media omitted>' ||
          signalMessage.body == 'This message was deleted') {
        addMessage = false;
        signalMessage = SignalMessage();
        continue;
      }

      if (senderName != contactName) {
        // Message was sent

        signalMessage.threadId = contactSignalThreadId;
        signalMessage.fromRecipientId = signalUserID;
        signalMessage.toRecipientId = contactSignalId;
        signalMessage.setSend();
      } else {
        // Message was received

        signalMessage.threadId = contactSignalThreadId;
        signalMessage.fromRecipientId = contactSignalId;
        signalMessage.toRecipientId = signalUserID;
        signalMessage.setReceived();
      }

      addMessage = true;
    }

    // Don't forget to add last message
    if (addMessage) {
      signalAddMessage(signalMessage);
    }
  }
}
