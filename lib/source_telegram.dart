import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:move_to_signal/signal_import.dart';
import 'package:move_to_signal/signal_message.dart';

class SourceTelegram extends SignalImport {
  File? telegramExport;

  @override
  run(List<String> arguments) {
    // Read all arguments
    for (final argument in arguments) {
      if (argument.startsWith('--telegramExport=')) {
        telegramExport = File(argument.split('=').last);
      }
    }

    if (verbose) print('Run Telegram import');

    super.run(arguments);

    if (verbose) print('Check missing Telegram arguments');

    if (telegramExport == null) {
      print('Missing argument --telegramExport');
      return;
    }

    if (verbose) print('Check Telegram Exports folder');

    if (!telegramExport!.existsSync()) {
      print('--telegramExport=${telegramExport!.path} file not found');
      return;
    }

    if (verbose) print('Parse Telegram JSON file');
    _parseTelegramJson();

    signalImport();
  }

  void _parseTelegramJson() {}
}
