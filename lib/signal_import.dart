import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:move_to_signal/signal_message.dart';
import 'package:move_to_signal/signal_thread.dart';
import 'package:sqlite3/sqlite3.dart';

class SignalImport {
  final List<SignalMessage> _signalMessages = [];
  final Map<int, SignalThread> _signalThreads = {};
  File? signalBackupFile;
  Directory _signalBackupDecryptFolder =
      Directory('./SignalBackupDecryptFolder');
  String signalBackupKey = '';
  String signalPhoneNumber = '';
  Database? _database;
  int signalUserID = 0;
  bool verbose = false;

  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--signalBackup=')) {
        signalBackupFile = File(argument.split('=').last);
      }
      if (argument.startsWith('--signalBackupKey=')) {
        signalBackupKey = argument.split('=').last;
      }
      if (argument.startsWith('--signalPhoneNumber=')) {
        signalPhoneNumber = argument.split('=').last;
      }
    }

    if (verbose) print('Check missing Signal arguments');

    // Check missing arguments
    if (signalBackupFile == null) {
      print('Missing argument --signalBackup');
      exit(1);
    }
    if (!signalBackupFile!.existsSync()) {
      print('--signalBackup=${signalBackupFile!.path} file not found');
      exit(1);
    }

    _signalBackupDecryptFolder = Directory(path.join(
        path.dirname(signalBackupFile!.path), _signalBackupDecryptFolder.path));

    if (signalBackupKey.isEmpty) {
      print('Missing argument --signalBackupKey');
      exit(1);
    }
    if (signalPhoneNumber.isEmpty) {
      print('Missing argument --signalPhoneNumber');
      exit(1);
    }
  }

  void signalDbOpen() {
    if (verbose) print('Check the database');

    if (!File('${_signalBackupDecryptFolder.path}/database.sqlite')
        .existsSync()) {
      print(
          'No database was found. Check backup file, key and folder arguments!');
      exit(1);
    }

    if (verbose) print('Open the database');

    _database = sqlite3.open(
      '${_signalBackupDecryptFolder.path}/database.sqlite',
      mode: OpenMode.readWrite,
    );

    if (verbose) print('Get recipient ID for number: $signalPhoneNumber');

    signalUserID = signalGetRecipientID(signalPhoneNumber);

    if (signalUserID == 0) {
      print('No recipient ID was found for number: $signalPhoneNumber');
      exit(1);
    }

    if (verbose) print('Found recipient ID: $signalUserID');
  }

  void signalDbClose() {
    if (verbose) print('Close the database');

    _database?.dispose();
  }

  void signalBackupDecrypt() {
    if (verbose) print('Prepare Signal backup folder');

    if (_signalBackupDecryptFolder.existsSync()) {
      _signalBackupDecryptFolder.deleteSync(recursive: true);
    }
    _signalBackupDecryptFolder.createSync();

    if (verbose) print('Decrypt Signal backup');

    Process.runSync('signalbackup-tools', [
      signalBackupFile!.path,
      signalBackupKey,
      '--output',
      _signalBackupDecryptFolder.path,
    ]);
  }

  void signalBackupEncrypt() {
    final signalBackup = path.join(path.dirname(signalBackupFile!.path),
        '${path.basenameWithoutExtension(signalBackupFile!.path)}_WAImported.backup');

    if (verbose) {
      print(
          'Encrypt Signal backup as: ${path.basenameWithoutExtension(signalBackupFile!.path)}_WAImported.backup');
    }

    Process.runSync('signalbackup-tools', [
      _signalBackupDecryptFolder.path,
      '--output',
      signalBackup,
      '--opassword',
      signalBackupKey,
    ]);

    if (verbose) print('Clean up');

    if (_signalBackupDecryptFolder.existsSync()) {
      _signalBackupDecryptFolder.deleteSync(recursive: true);
    }
  }

  void signalAddMessage(SignalMessage signalMessage) {
    if (signalMessage.threadId == 0) {
      return;
    }

    // Get max length for preview
    final maxLength =
        signalMessage.body.length > 100 ? 100 : signalMessage.body.length;

    // Check if thread exists
    if (!_signalThreads.containsKey(signalMessage.threadId)) {
      _signalThreads[signalMessage.threadId] = SignalThread();
    }

    // Update thread if date is older than new message
    if (_signalThreads[signalMessage.threadId]!.date <
        (signalMessage.dateSent ?? 0)) {
      _signalThreads[signalMessage.threadId]!.threadId = signalMessage.threadId;
      _signalThreads[signalMessage.threadId]!.date = signalMessage.dateSent!;
      _signalThreads[signalMessage.threadId]!.lastSeen =
          signalMessage.dateSent!;
      _signalThreads[signalMessage.threadId]!.snippet =
          signalMessage.body.substring(0, maxLength);
      _signalThreads[signalMessage.threadId]!.snippetType = signalMessage.type;
    }

    _signalMessages.add(signalMessage);
  }

  void signalImport() {
    if (_database == null) {
      signalDbOpen();
    }

    if (verbose) {
      print('Start Signal database import');
      print('Import ${_signalMessages.length} messages');
      print('0% done');
    }

    // Prepare a statement to run it multiple times:
    final messageImport = _database!.prepare(
      'INSERT INTO message '
      '('
      'date_sent,date_received,date_server,thread_id,from_recipient_id,from_device_id,'
      'to_recipient_id,type,body,read,m_type,st,receipt_timestamp,has_delivery_receipt,has_read_receipt,unidentified,'
      'reactions_last_seen,notified_timestamp'
      ') '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    );

    // Import all messages
    var counter = 0;
    var step = (_signalMessages.length / 10).ceil();
    var steps = 1;
    for (final signalMessage in _signalMessages) {
      messageImport.execute([
        signalMessage.dateSent,
        signalMessage.dateReceived,
        signalMessage.dateServer,
        signalMessage.threadId,
        signalMessage.fromRecipientId,
        signalMessage.fromDeviceId,
        signalMessage.toRecipientId,
        signalMessage.type,
        signalMessage.body,
        signalMessage.read,
        signalMessage.mType,
        signalMessage.st,
        signalMessage.receiptTimestamp,
        signalMessage.hasDeliveryReceipt,
        signalMessage.hasReadReceipt,
        signalMessage.unidentified,
        signalMessage.reactionsLastSeen,
        signalMessage.notifiedTimestamp,
      ]);

      if (!verbose) continue;

      counter++;
      if (counter == step) {
        print('${steps * 10}% done');
        steps++;
        counter = 0;
      }
    }
    if (verbose) print('100% done');

    if (verbose) print('Update threads');

    // Prepare a statement to run it multiple times:
    final threadUpdate = _database!.prepare(
      'UPDATE thread '
      'SET '
      'date=?,'
      'last_seen=?,'
      'snippet=?,'
      'snippet_type=?'
      'WHERE _id=? and date > ?',
    );

    // Update all threads
    for (final signalThread in _signalThreads.entries) {
      threadUpdate.execute([
        signalThread.value.date,
        signalThread.value.lastSeen,
        signalThread.value.snippet,
        signalThread.value.snippetType,
        signalThread.value.threadId,
        signalThread.value.date,
      ]);
    }

    signalDbClose();

    signalBackupEncrypt();
  }

  int signalGetRecipientID(String signalPhoneNumber) {
    if (_database == null) {
      signalDbOpen();
    }

    ResultSet results = _database!.select(
        'select _id from recipient where e164 = "$signalPhoneNumber" limit 1;');

    if (results.isEmpty) {
      return 0;
    }

    var id = results.first.columnAt(0);
    if (id is int) {
      return id;
    }

    return 0;
  }

  int signalGetThreadID(int signalRecipientID) {
    if (_database == null) {
      signalDbOpen();
    }

    ResultSet results = _database!.select(
        'select _id from thread where recipient_id = $signalRecipientID limit 1;');

    if (results.isEmpty) {
      return 0;
    }

    var id = results.first.columnAt(0);
    if (id is int) {
      return id;
    }

    return 0;
  }
}
