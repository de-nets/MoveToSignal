import 'dart:convert';
import 'dart:io';
import 'package:move_to_signal/model/signal_reaction.dart';
import 'package:move_to_signal/model/whats_app_message.dart';
import 'package:move_to_signal/model/whats_app_participant.dart';
import 'package:move_to_signal/model/whats_app_reaction.dart';
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

    super.run(arguments);

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

      signalDbClose();
    }

    if (_whatsAppMode == 'Import') {
      if (verbose) print('Run in WhatsApp import mode');

      if (!_whatsAppExportsFolder.existsSync()) {
        print(
            'Folder $_whatsAppExportsFolder not found. Did you run prepare mode first?');
        return;
      }

      super.run(arguments);

      _whatsAppExportsFolder.listSync().forEach((whatsAppExport) {
        if (whatsAppExport is File && whatsAppExport.path.endsWith('.json')) {
          _parseWhatsAppExport(whatsAppExport);
        }
      });

      signalImport();
    }
  }

  void _parseWhatsAppDb() {
    if (verbose) print('Open the WhatsApp database');

    _database = sqlite3.open(
      _whatsAppDb!.path,
      mode: OpenMode.readOnly,
    );

    WhatsAppThread whatsAppThread;

    // Get all 1 on 1 threads
    ResultSet directChats = _database.select(
        'SELECT chat._id, jid.raw_string, jid._id AS contactId, jid.user AS phoneNumber '
        'FROM chat '
        'LEFT JOIN jid ON chat.jid_row_id = jid._id '
        'WHERE jid.raw_string like "%@s.whatsapp.net";');

    if (verbose) print('Get all 1 on 1 messages and reactions');

    for (final directChat in directChats) {
      whatsAppThread = WhatsAppThread();

      whatsAppThread.id = directChat['_id'];
      whatsAppThread.phoneNumber =
          _parseWhatsAppUser(directChat['phoneNumber'].toString());
      whatsAppThread.fromId = directChat['raw_string'];

      whatsAppThread.name =
          signalGetRecipientName(whatsAppThread.phoneNumber) ?? '';

      whatsAppThread = _getWhatsAppMessages(whatsAppThread);

      if (whatsAppThread.messages.isNotEmpty) {
        _whatsAppThreads.add(whatsAppThread);
      }
    }

    // Get all group threads
    ResultSet groupChats = _database.select(
        'SELECT chat._id, jid.raw_string, chat.subject, chat.created_timestamp, jid._id AS groupId '
        'FROM chat '
        'LEFT JOIN jid ON chat.jid_row_id = jid._id '
        'WHERE jid.raw_string like "%@g.us";');

    if (verbose) print('Get all group messages and reactions');
    for (final groupChat in groupChats) {
      whatsAppThread = WhatsAppThread();

      whatsAppThread.id = groupChat['_id'];
      whatsAppThread.fromId = groupChat['raw_string'];
      whatsAppThread.isGroup = true;
      whatsAppThread.name = groupChat['subject'].toString();
      whatsAppThread.createdTimestamp = groupChat['created_timestamp'];

      // Get groups
      ResultSet groupParticipants = _database.select(
          'SELECT group_participant_user.user_jid_row_id, group_participant_user.rank, jid.user, jid.raw_string '
          'FROM group_participant_user '
          'LEFT JOIN jid ON jid._id = group_participant_user.user_jid_row_id '
          'WHERE group_participant_user.group_jid_row_id = ${groupChat['groupId']};');

      for (final groupParticipant in groupParticipants) {
        final WhatsAppParticipant whatsAppParticipant = WhatsAppParticipant();
        whatsAppParticipant.id = groupParticipant['user_jid_row_id'];
        var phoneNumber = groupParticipant['user'].toString();
        if (groupParticipant['raw_string'].toString() == 'status_me') {
          phoneNumber = signalPhoneNumber;
        }
        whatsAppParticipant.phoneNumber = _parseWhatsAppUser(phoneNumber);

        whatsAppParticipant.rank = groupParticipant['rank'];
        whatsAppThread.participants.add(whatsAppParticipant);
        if (groupParticipant['rank'].toString() == '2') {
          whatsAppThread.phoneNumber = _parseWhatsAppUser(phoneNumber);
          whatsAppThread.fromId = groupParticipant['raw_string'].toString();
        }
      }
      if (whatsAppThread.phoneNumber.isEmpty) {
        final fromIdSplit = whatsAppThread.fromId.split('@');
        if (fromIdSplit.length == 2) {
          final phoneNumberSplit = fromIdSplit[0].split('-');
          if (phoneNumberSplit.length == 2) {
            whatsAppThread.phoneNumber =
                _parseWhatsAppUser(phoneNumberSplit[0]);
          }
        }
      }

      whatsAppThread = _getWhatsAppMessages(whatsAppThread);

      if (whatsAppThread.messages.isNotEmpty) {
        _whatsAppThreads.add(whatsAppThread);
      }
    }

    _database.dispose();
  }

  WhatsAppThread _getWhatsAppMessages(WhatsAppThread whatsAppThread) {
    List<WhatsAppMessage> whatsAppMessages = [];

    // Get all messages for this thread
    ResultSet messages = _database.select(
      'SELECT '
      'message._id, '
      'message.message_type, '
      'message.text_data, '
      'message.from_me, '
      'message.status, '
      'message.timestamp, '
      'message.received_timestamp, '
      'message.receipt_server_timestamp, '
      'jid._id AS contactId, '
      'jid.user AS phoneNumber '
      'FROM message '
      'LEFT JOIN jid ON jid._id = message.sender_jid_row_id '
      'WHERE message.chat_row_id=${whatsAppThread.id};',
    );

    for (final message in messages) {
      final String? text = message['text_data'];
      if (text == null || text.isEmpty) {
        // Ignore empty messages
        continue;
      }

      final WhatsAppMessage whatsAppMessage = WhatsAppMessage();

      if (whatsAppThread.isGroup && message['contactId'] != null) {
        if (whatsAppThread.participants.indexWhere(
                (participant) => participant.id == message['contactId']) ==
            -1) {
          final participant = WhatsAppParticipant();
          participant.id = message['contactId'];
          participant.rank = -1;
          participant.phoneNumber =
              _parseWhatsAppUser(message['phoneNumber'].toString());
          whatsAppThread.participants.add(participant);
        }
        whatsAppMessage.contactId = message['contactId'];
      }

      if (message['from_me'] == 1) {
        whatsAppMessage.fromMe = true;
      }

      if (whatsAppMessage.fromMe && message['status'] == 13) {
        whatsAppMessage.read = 1;
      }

      whatsAppMessage.text = message['text_data'];
      whatsAppMessage.type = message['message_type'];
      whatsAppMessage.timestamp = message['timestamp'];
      whatsAppMessage.receivedTimestamp = message['received_timestamp'];
      whatsAppMessage.receiptServerTimestamp =
          message['receipt_server_timestamp'];

      whatsAppMessage.reactions =
          _getWhatsAppReactions(message['_id'].toString());

      whatsAppMessages.add(whatsAppMessage);
    }

    whatsAppThread.messages = whatsAppMessages;

    return whatsAppThread;
  }

  String _parseWhatsAppUser(String user) {
    if (user.isNotEmpty && !user.startsWith('+', 0)) {
      user = '+$user';
    }
    return user;
  }

  List<WhatsAppReaction> _getWhatsAppReactions(String messageId) {
    List<WhatsAppReaction> whatsAppReactions = [];
    // Get all reactions for this message
    ResultSet reactions = _database.select(
      'SELECT '
      'message_add_on_reaction.reaction, '
      'message_add_on_reaction.sender_timestamp, '
      'message_add_on.received_timestamp, '
      'message_add_on.from_me, '
      'message_add_on.sender_jid_row_id AS contactId '
      'FROM message_add_on '
      'LEFT JOIN message_add_on_reaction ON message_add_on_reaction.message_add_on_row_id = message_add_on._id '
      'WHERE message_add_on.parent_message_row_id=${messageId};',
    );

    for (final reaction in reactions) {
      if (reaction['reaction'] == null) {
        continue;
      }

      final WhatsAppReaction whatsAppReaction = WhatsAppReaction();

      whatsAppReaction.reaction = reaction['reaction'];
      whatsAppReaction.contactId = reaction['contactId'];

      if (reaction['from_me'] == 1) {
        whatsAppReaction.fromMe = true;
      }

      whatsAppReaction.sendTimestamp = reaction['sender_timestamp'];
      whatsAppReaction.receivedTimestamp = reaction['received_timestamp'];

      whatsAppReactions.add(whatsAppReaction);
    }

    return whatsAppReactions;
  }

  void _parseWhatsAppExport(File whatsAppExport) {
    if (verbose) {
      print('Parse WhatsApp export: ${path.basename(whatsAppExport.path)}');
    }

    // Read WhatsApp export file
    final thread = WhatsAppThread()
        .fromDynamic(jsonDecode(whatsAppExport.readAsStringSync()));

    if (thread.isGroup) {
    } else {
      // Get contact date from filename
      final contactNumber = thread.phoneNumber;
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
      SignalMessage signalMessage;

      for (final message in thread.messages) {
        signalMessage = SignalMessage();

        signalMessage.messageDateTime = message.timestamp;
        signalMessage.body = message.text;

        if (message.fromMe) {
          // Message was sent

          signalMessage.threadId = contactSignalThreadId;
          signalMessage.fromRecipientId = signalUserID;
          signalMessage.toRecipientId = contactSignalId;
          signalMessage.setSend();
          if (message.receivedTimestamp != 0) {
            signalMessage.dateReceived = message.receivedTimestamp;
          }
          if (message.receiptServerTimestamp != 0) {
            signalMessage.receiptTimestamp = message.receiptServerTimestamp;
          }
        } else {
          // Message was received

          signalMessage.threadId = contactSignalThreadId;
          signalMessage.fromRecipientId = contactSignalId;
          signalMessage.toRecipientId = signalUserID;
          signalMessage.setReceived();
          if (message.receivedTimestamp != 0) {
            signalMessage.dateReceived = message.receivedTimestamp;
          }
          if (message.receiptServerTimestamp != 0) {
            signalMessage.receiptTimestamp = message.receiptServerTimestamp;
          }
        }

        for (final reaction in message.reactions) {
          final signalReaction = SignalReaction();

          if (reaction.reaction == null || reaction.reaction!.isEmpty) {
            continue;
          }

          signalReaction.fromMe = reaction.fromMe;

          if (signalReaction.fromMe!) {
            signalReaction.authorId = signalUserID;
          } else {
            signalReaction.authorId = contactSignalId;
          }
          signalReaction.reaction = reaction.reaction;
          signalReaction.sendTimestamp = reaction.sendTimestamp;
          signalReaction.receivedTimestamp = reaction.receivedTimestamp;

          signalMessage.reactions.add(signalReaction);
        }

        signalAddMessage(signalMessage);
      }
    }
  }

  void _writeWhatsAppExport() {
    if (verbose) print('Create WhatsApp export folder.');

    if (_whatsAppExportsFolder.existsSync()) {
      _whatsAppExportsFolder.deleteSync(recursive: true);
    }

    _whatsAppExportsFolder.createSync();

    if (verbose) print('Export WhatsApp threads to files.');

    for (final whatsAppThread in _whatsAppThreads) {
      String fileName = whatsAppThread.phoneNumber;
      if (fileName.isEmpty) {
        fileName = whatsAppThread.fromId;
      }

      fileName =
          '${whatsAppThread.isGroup ? 'GroupChat' : 'DirectChat'}-$fileName-${whatsAppThread.name}.json';

      final filePath = path.join(_whatsAppExportsFolder.path, fileName);
      final export = File(filePath).openSync(mode: FileMode.writeOnlyAppend);

      if (verbose) print('Export: $fileName');

      export.writeStringSync(whatsAppThread.toString());

      export.closeSync();
    }
  }
}
