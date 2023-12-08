import 'dart:convert';
import 'dart:io';
import 'package:move_to_signal/model/signal_message.dart';
import 'package:move_to_signal/model/telegram_message.dart';
import 'package:move_to_signal/model/telegram_thread.dart';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/import/signal.dart';

class Telegram extends Signal {
  String telegramMode = 'Prepare';
  String telegramExports = '';
  Directory _telegramExportsFolder = Directory('./TelegramExportsFolder');

  File? telegramJson;
  final List<TelegramThread> _telegramThreads = [];

  // List of users to ignore
  final List<String> _userIgnore = [
    'user777000', // Telegram Chatbot
  ];

  @override
  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--telegramJson=')) {
        telegramJson = File(argument.split('=').last);
      }
      if (argument.startsWith('--telegramMode=')) {
        telegramMode = argument.split('=').last;
      }
      if (argument.startsWith('--telegramExports=')) {
        telegramExports = argument.split('=').last;
      }
    }

    if (verbose) print('Check missing general Telegram arguments');

    if (telegramExports.isEmpty) {
      print('Missing argument --telegramExports');
      return;
    }

    if (verbose) print('Check Telegram Exports folder');

    if (!Directory(telegramExports).existsSync()) {
      print('--telegramExports=$telegramExports folder not found');
      return;
    }

    _telegramExportsFolder =
        Directory(path.join(telegramExports, _telegramExportsFolder.path));

    if (telegramMode == 'ListUser') {
      if (verbose) print('Run in Telegram list user mode');

      if (verbose) print('Check missing prepare Telegram arguments');

      if (telegramJson == null) {
        print('Missing argument --telegramJson');
        return;
      }

      if (!telegramJson!.existsSync()) {
        print('--telegramJson=${telegramJson!.path} file not found');
        return;
      }

      if (verbose) print('Parse Telegram JSON file');

      _parseTelegramJson();

      _listUserId();
    }

    if (telegramMode == 'Prepare') {
      if (verbose) print('Run in Telegram prepare mode');

      if (verbose) print('Check missing prepare Telegram arguments');

      if (telegramJson == null) {
        print('Missing argument --telegramJson');
        return;
      }

      if (!telegramJson!.existsSync()) {
        print('--telegramJson=${telegramJson!.path} file not found');
        return;
      }

      if (verbose) print('Parse Telegram JSON file');

      _parseTelegramJson();

      if (verbose) print('Write parsed Telegram JSON to tmp folder');

      _writeTelegramExport();

      print('');
      print('');
      print('Messages threads exported to: ${_telegramExportsFolder.path}');
      print('');
      print(
          'Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.');
      print(
          'At this point you can also merge files into one, if a user had multiple Telegram identities.');
      print('Please delete all files you don\'t want to import.');
      print('');
      print('A valid file name looks like: +4912345678-Contact Name.txt');
      print(
          'The phone number needs to in international format starting with + and must only contain numbers.');
      print('');
      print('Once you are done, you can start the import process.');
      print('');
    }

    if (telegramMode == 'Import') {
      if (verbose) print('Run in Telegram import mode');

      if (!_telegramExportsFolder.existsSync()) {
        print(
            'Folder $_telegramExportsFolder not found. Did you run prepare mode first?');
        return;
      }

      super.run(arguments);

      _telegramExportsFolder.listSync().forEach((telegramExport) {
        if (telegramExport is File && telegramExport.path.endsWith('.txt')) {
          _parseTelegramExport(telegramExport);
        }
      });

      signalImport();
    }
  }

  void _listUserId() {
    for (final telegramThread in _telegramThreads) {
      print(
          '${telegramThread.fromId}-${telegramThread.phoneNumber}-${telegramThread.name}');
    }
  }

  void _parseTelegramExport(File telegramExport) {
    if (verbose) {
      print('Parse Telegram export: ${path.basename(telegramExport.path)}');
    }

    var filename = path.basenameWithoutExtension(telegramExport.path);
    var filenameParts = filename.split('-');

    if (filenameParts.length != 2) {
      print('File name format error ${telegramExport.path}');
      return;
    }

    // Get contact date from filename
    final contactNumber = filenameParts[0];
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
    final messages = jsonDecode(telegramExport.readAsStringSync());

    for (final message in messages) {
      signalMessage.messageDateTime = message['date'] * 1000;
      signalMessage.body = message['text'];

      if (message['received']) {
        // Message was received

        signalMessage.threadId = contactSignalThreadId;
        signalMessage.fromRecipientId = contactSignalId;
        signalMessage.toRecipientId = signalUserID;
        signalMessage.setReceived();
      } else {
        // Message was sent

        signalMessage.threadId = contactSignalThreadId;
        signalMessage.fromRecipientId = signalUserID;
        signalMessage.toRecipientId = contactSignalId;
        signalMessage.setSend();
      }

      signalAddMessage(signalMessage);
      signalMessage = SignalMessage();
    }
  }

  void _parseTelegramJson() {
    // Read Telegram json file
    final telegramExportFile = telegramJson!.readAsStringSync();

    // Decode json string to object
    final telegramExportJson = jsonDecode(telegramExportFile);

    // Get Telegram account data
    final telegramUserId =
        telegramExportJson['personal_information']['user_id'];

    // List of text entity types to ignore
    List<String> typeIgnore = [
      'underline',
      'bold',
      'italic',
    ];

    // Build map for user name to phone number
    Map<String, String> userPhoneNumber = {};

    // Get all contacts
    final contacts = telegramExportJson['contacts']['list'] ?? [];
    if (contacts is List) {
      for (final contact in contacts) {
        String name = contact['first_name'] ?? '';
        if (name.isNotEmpty && contact['last_name'] != '') {
          name = '$name ';
        }
        name = '$name${contact['last_name']}';

        if (name.isEmpty) {
          continue;
        }

        if (userPhoneNumber.keys.contains(name)) {
          continue;
        }

        var phoneNumber = contact['phone_number'];

        // Filter numbers and +
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]+'), '');

        // if number start with 00 replace by +
        phoneNumber = phoneNumber.replaceAll(RegExp(r'^00'), '+');

        userPhoneNumber[name] = phoneNumber;
      }
    }

    // Get all chats
    final chats = telegramExportJson['chats']['list'] ?? [];
    if (chats is List) {
      for (final chat in chats) {
        // Setup new telegram thread
        final telegramThread = TelegramThread();

        // Get all messages
        final messages = chat['messages'] ?? [];
        if (messages is List) {
          for (final message in messages) {
            // Ignore message from user if on ignore list
            if (_userIgnore.contains(message['from_id'])) {
              continue;
            }

            // Ignore all other message types than message
            if ((message['type'] ?? '') != 'message') {
              continue;
            }

            // Setup new telegram message
            final telegramMessage = TelegramMessage();
            telegramMessage.date = int.parse(message['date_unixtime']);
            telegramMessage.from = message['from'] ?? '';
            telegramMessage.fromId = message['from_id'] ?? '';

            // Get all text entities
            final textEntities = message['text_entities'] ?? false;
            if (textEntities is List) {
              for (final textEntity in textEntities) {
                // Ignore text entities if on ignore list
                if (typeIgnore.contains(textEntity['type'])) {
                  continue;
                }

                // Ignore empty text entities
                if (textEntity['text'] == '') {
                  continue;
                }

                // Build message from entity
                telegramMessage.text += textEntity['text'];
              }
            } else {
              // if text_entities is not a list use the message text
              telegramMessage.text = message['text'];
            }

            // Ignore message if no text at all, most likely a picture, file, video or voice chat
            if (telegramMessage.text.isEmpty) {
              continue;
            }

            // Fill telegramMessage data
            if (telegramThread.name.isEmpty &&
                telegramMessage.fromId != 'user$telegramUserId') {
              telegramThread.name = telegramMessage.from;
              telegramThread.fromId = telegramMessage.fromId;
            }

            // Set received flag to false if message was send
            if (telegramMessage.fromId == 'user$telegramUserId') {
              telegramMessage.received = false;
            }

            // Add message to thread
            telegramThread.messages.add(telegramMessage);
          }
        }

        // Try and find phone number in map
        if (userPhoneNumber.keys.contains(telegramThread.name)) {
          telegramThread.phoneNumber =
              userPhoneNumber[telegramThread.name] ?? '';
        }

        // Ignore empty threads
        if (telegramThread.messages.isEmpty) {
          continue;
        }

        // Get name from thread if still empty
        if (telegramThread.name.isEmpty) {
          telegramThread.name = chat['name'] ?? chat['id'].toString();
        }

        // Sort thread messages by timestamp
        telegramThread.messages.sort((a, b) => a.date.compareTo(b.date));
        _telegramThreads.add(telegramThread);
      }
    }
  }

  void _writeTelegramExport() {
    if (verbose) print('Create Telegram export folder.');

    if (_telegramExportsFolder.existsSync()) {
      _telegramExportsFolder.deleteSync(recursive: true);
    }

    _telegramExportsFolder.createSync();

    if (verbose) print('Export Telegram threads to files.');

    for (final telegramThread in _telegramThreads) {
      String fileName = telegramThread.phoneNumber;
      if (fileName.isEmpty) {
        fileName = telegramThread.fromId;
      }

      fileName = '$fileName-${telegramThread.name}.txt';

      final filePath = path.join(_telegramExportsFolder.path, fileName);
      final export = File(filePath).openSync(mode: FileMode.writeOnlyAppend);

      if (verbose) print('Export: $fileName');

      export.writeStringSync("[\n");
      var firstLine = true;
      for (final message in telegramThread.messages) {
        if (!firstLine) {
          export.writeStringSync(",\n");
        } else {
          firstLine = false;
        }
        export.writeStringSync("${message.toJson()}");
      }
      export.writeStringSync("\n]");

      export.closeSync();
    }
  }
}
