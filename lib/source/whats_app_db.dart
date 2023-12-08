import 'dart:io';
import 'package:move_to_signal/model/whats_app_message.dart';
import 'package:move_to_signal/model/whats_app_thread.dart';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/import/signal.dart';
import 'package:move_to_signal/model/signal_message.dart';
import 'package:sqlite3/sqlite3.dart';

class WhatsAppDb extends Signal {
  String _whatsAppMode = 'Prepare';
  String _whatsAppExports = '';
  File? _whatsAppDb;
  late Database _database;

  Directory _whatsAppExportsFolder = Directory('./WhatsAppExportsFolder');
  final List<WhatsAppThread> _whatsAppThreads = [];

  @override
  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--whatsAppDb=')) {
        _whatsAppDb = File(argument.split('=').last);
      }
      if (argument.startsWith('--whatsAppMode=')) {
        _whatsAppMode = argument.split('=').last;
      }

      if (argument.startsWith('--whatsAppExports=')) {
        _whatsAppExports = argument.split('=').last;
      }
    }

    if (verbose) print('Check missing general WhatsApp arguments');

    if (_whatsAppExports.isEmpty) {
      print('Missing argument --whatsAppExports');
      return;
    }

    if (verbose) print('Check WhatsApp Exports folder');

    if (!Directory(_whatsAppExports).existsSync()) {
      print('--whatsAppExports=$_whatsAppExports folder not found');
      return;
    }

    _whatsAppExportsFolder =
        Directory(path.join(_whatsAppExports, _whatsAppExportsFolder.path));

    if (_whatsAppMode == 'Prepare') {
      if (verbose) print('Run in WhatsApp prepare mode');

      if (verbose) print('Check missing prepare WhatsApp arguments');

      if (_whatsAppDb == null) {
        print('Missing argument --whatsAppDb');
        return;
      }

      if (!_whatsAppDb!.existsSync()) {
        print('--whatsAppDb=${_whatsAppDb!.path} file not found');
        return;
      }

      if (verbose) print('Parse WhatsApp DB');

      _parseWhatsAppDb();

      if (verbose) print('Write parsed WhatsApp DB to tmp folder');

      _writeWhatsAppExport();

      print('');
      print('');
      print('Messages threads exported to: ${_whatsAppExportsFolder.path}');
      print('');
      print(
          'Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.');
      print(
          'At this point you can also merge files into one, if a user had multiple WhatsApp identities.');
      print('Please delete all files you don\'t want to import.');
      print('');
      print('A valid file name looks like: +4912345678-Contact Name.txt');
      print(
          'The phone number needs to in international format starting with + and must only contain numbers.');
      print('');
      print('Once you are done, you can start the import process.');
      print('');
    }
  }

  void _parseWhatsAppDb() {
    if (verbose) print('Open the WhatsApp database');

    _database = sqlite3.open(
      _whatsAppDb!.path,
      mode: OpenMode.readOnly,
    );

    // Get all 1 on 1 threads
    ResultSet threads = _database.select(
        'SELECT _id, raw_string_jid FROM chat_view WHERE raw_string_jid like "%@s.whatsapp.net";');

    for (final thread in threads) {
      // Get phone number
      final jid = thread['raw_string_jid'];
      final jidSplit = jid.split('@');
      if (jidSplit.length != 2) {
        // Something went wrong
        if (verbose) print('Something went wrong: $thread');

        continue;
      }

      final WhatsAppThread whatsAppThread = WhatsAppThread();
      whatsAppThread.id = thread['_id'].toString();
      whatsAppThread.phoneNumber = '+${jidSplit[0]}';
      whatsAppThread.fromId = jid;

      // Get all messages for this thread
      ResultSet messages = _database.select(
          'SELECT * FROM message WHERE chat_row_id=${whatsAppThread.id};');

      for (final message in messages) {
        final String? text = message['text_data'];
        if (text == null || text.isEmpty) {
          // Ignore empty messages
          continue;
        }

        final WhatsAppMessage whatsAppMessage = WhatsAppMessage();
        if (message['from_me'] != 1) {
          whatsAppMessage.fromMe = false;
        }

        if (whatsAppMessage.fromMe && message['status'] == 13) {
          whatsAppMessage.read = 1;
        }

        whatsAppMessage.text = message['text_data'];
        whatsAppMessage.timestamp = message['timestamp'];
        whatsAppMessage.receivedTimestamp = message['received_timestamp'];
        whatsAppMessage.receiptServerTimestamp =
            message['receipt_server_timestamp'];
        whatsAppThread.messages.add(whatsAppMessage);
      }

      if (whatsAppThread.messages.isNotEmpty) {
        _whatsAppThreads.add(whatsAppThread);
      }
    }

    _database.dispose();
  }

  void _writeWhatsAppExport() {
    if (verbose) print('Create Telegram export folder.');

    if (_whatsAppExportsFolder.existsSync()) {
      _whatsAppExportsFolder.deleteSync(recursive: true);
    }

    _whatsAppExportsFolder.createSync();

    if (verbose) print('Export Telegram threads to files.');

    for (final whatsAppThread in _whatsAppThreads) {
      String fileName = whatsAppThread.phoneNumber;
      if (fileName.isEmpty) {
        fileName = whatsAppThread.fromId;
      }

      fileName = '$fileName-${whatsAppThread.name}.txt';

      final filePath = path.join(_whatsAppExportsFolder.path, fileName);
      final export = File(filePath).openSync(mode: FileMode.writeOnlyAppend);

      if (verbose) print('Export: $fileName');

      export.writeStringSync("[\n");
      var firstLine = true;
      for (final message in whatsAppThread.messages) {
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
