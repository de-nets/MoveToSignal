import 'dart:convert';
import 'dart:io';
import 'package:move_to_signal/telegram_message.dart';
import 'package:move_to_signal/telegram_thread.dart';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/signal_import.dart';

class SourceTelegram extends SignalImport {
  String telegramMode = 'Prepare';
  String telegramExports = '';
  late Directory _telegramExportsFolder;
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

    _telegramExportsFolder = Directory(path.join(telegramExports, 'telegram'));

//    super.run(arguments);
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


    if (verbose) print('Parse Telegram JSON file');
    _parseTelegramJson();

  }

  void _listUserId() {
    for (final telegramThread in _telegramThreads) {
      print(
          '${telegramThread.fromId}-${telegramThread.phoneNumber}-${telegramThread.name}');
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

      for (final message in telegramThread.messages) {
        export.writeStringSync(
            "${message.date}|${message.received}|${message.from}|${message.text}\n");
      }

      export.closeSync();
    }
  }
}
