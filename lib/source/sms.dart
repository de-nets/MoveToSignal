import 'dart:convert';
import 'dart:io';
import 'package:move_to_signal/model/signal_message.dart';
import 'package:move_to_signal/model/sms_message.dart';
import 'package:move_to_signal/model/sms_thread.dart';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/import/signal.dart';
import 'package:xml/xml.dart';

class Sms extends Signal {
  String _smsMode = 'Prepare';
  String _smsExports = '';
  Directory _smsExportsFolder = Directory('./SmsExportsFolder');
  File? _smsXml;

  final Map<String, SmsThread> _smsThreads = {};

  @override
  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--smsXml=')) {
        _smsXml = File(argument.split('=').last);
      }
      if (argument.startsWith('--smsMode=')) {
        _smsMode = argument.split('=').last;
      }
      if (argument.startsWith('--smsExports=')) {
        _smsExports = argument.split('=').last;
      }
    }

    if (verbose) print('Check missing general SMS arguments');

    if (_smsExports.isEmpty) {
      print('Missing argument --smsExports');
      return;
    }

    if (verbose) print('Check SMS Exports folder');

    if (!Directory(_smsExports).existsSync()) {
      print('--smsExports=$_smsExports folder not found');
      return;
    }

    _smsExportsFolder =
        Directory(path.join(_smsExports, _smsExportsFolder.path));

    if (_smsMode == 'Prepare') {
      if (verbose) print('Run in SMS prepare mode');

      if (verbose) print('Check missing prepare SMS arguments');

      if (_smsXml == null) {
        print('Missing argument --smsXml');
        return;
      }

      if (!_smsXml!.existsSync()) {
        print('--smsXml=${_smsXml!.path} file not found');
        return;
      }

      if (verbose) print('Parse SMS XML file');

      _parseSmsXml();

      if (verbose) print('Write parsed SMS XML to tmp folder');

      _writeSmsExport();

      print('');
      print('');
      print('Messages threads exported to: ${_smsExportsFolder.path}');
      print('');
      print(
          'Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.');
      print(
          'At this point you can also merge files into one, if a user had multiple SMS identities.');
      print('Please delete all files you don\'t want to import.');
      print('');
      print('A valid file name looks like: +4912345678-Contact Name.txt');
      print(
          'The phone number needs to in international format starting with + and must only contain numbers.');
      print('');
      print('Once you are done, you can start the import process.');
      print('');
    }

    if (_smsMode == 'Import') {
      if (verbose) print('Run in SMS import mode');

      if (!_smsExportsFolder.existsSync()) {
        print(
            'Folder $_smsExportsFolder not found. Did you run prepare mode first?');
        return;
      }

      super.run(arguments);

      _smsExportsFolder.listSync().forEach((smsExport) {
        if (smsExport is File && smsExport.path.endsWith('.txt')) {
          _parseSmsExport(smsExport);
        }
      });

      signalImport();
    }
  }

  void _parseSmsExport(File smsExport) {
    if (verbose) {
      print('Parse SMS export: ${path.basename(smsExport.path)}');
    }

    var filename = path.basenameWithoutExtension(smsExport.path);
    var filenameParts = filename.split('-');

    if (filenameParts.length != 2) {
      print('File name format error ${smsExport.path}');
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

    // Read SMS export file
    final messages = jsonDecode(smsExport.readAsStringSync());

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

  void _parseSmsXml() {
    // Read SMS XML file
    final smsXmlFile = _smsXml!.readAsStringSync();

    // Decode json string to object
    final smsXmlDocument = XmlDocument.parse(smsXmlFile);

    final smses = smsXmlDocument.findAllElements('sms');

    for (final sms in smses) {
      final smsMessage = SmsMessage();
      smsMessage.date = int.parse(sms.getAttribute('date') ?? '0');

      smsMessage.from = sms.getAttribute('address') ?? '';

      // Filter numbers and +
      smsMessage.from = smsMessage.from.replaceAll(RegExp(r'[^0-9+]+'), '');

      // if number start with 00 replace by +
      smsMessage.from = smsMessage.from.replaceAll(RegExp(r'^00'), '+');

      smsMessage.text = sms.getAttribute('body') ?? '';

      if ((sms.getAttribute('type') ?? '') == '2') {
        smsMessage.received = false;
      }

      var smsThread = _smsThreads[smsMessage.from];
      if (smsThread == null) {
        smsThread = SmsThread();
        smsThread.phoneNumber = smsMessage.from;
        smsThread.name = sms.getAttribute('contact_name') ?? '';
        smsThread.messages.add(smsMessage);
        _smsThreads[smsMessage.from] = smsThread;
      } else {
        smsThread.messages.add(smsMessage);
      }
    }
  }

  void _writeSmsExport() {
    if (verbose) print('Create SMS export folder.');

    if (_smsExportsFolder.existsSync()) {
      _smsExportsFolder.deleteSync(recursive: true);
    }

    _smsExportsFolder.createSync();

    if (verbose) print('Export SMS threads to files.');

    for (final smsThread in _smsThreads.values) {
      String fileName = smsThread.phoneNumber;

      fileName = '$fileName-${smsThread.name}.txt';

      final filePath = path.join(_smsExportsFolder.path, fileName);
      final export = File(filePath).openSync(mode: FileMode.writeOnlyAppend);

      if (verbose) print('Export: $fileName');

      export.writeStringSync("[\n");
      var firstLine = true;
      for (final message in smsThread.messages) {
        if (!firstLine) {
          export.writeStringSync(",\n");
        } else {
          firstLine = false;
        }
        export.writeStringSync(message.toString());
      }
      export.writeStringSync("\n]");

      export.closeSync();
    }
  }
}
