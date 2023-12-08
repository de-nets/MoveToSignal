import 'package:move_to_signal/signal_import.dart';
import 'package:move_to_signal/source_telegram.dart';
import 'package:move_to_signal/source_whats_app.dart';

void main(List<String> arguments) {
  String command = 'ImportWhatsApp';
  bool verbose = false;

  // Read all arguments
  for (final argument in arguments) {
    if (argument == '--verbose') {
      verbose = true;
    }
    if (argument.startsWith('--command=')) {
      command = argument.split('=').last;
    }
  }

  switch (command) {
    case 'ImportTelegram':
      final telegramImport = SourceTelegram();
      telegramImport.verbose = verbose;
      telegramImport.run(arguments);

      break;
    case 'ImportWhatsApp':
      final whatsAppImport = SourceWhatsApp();
      whatsAppImport.verbose = verbose;
      whatsAppImport.run(arguments);

      break;
    case 'SignalDecrypt':
      final signalDecrypt = SignalImport();
      signalDecrypt.verbose = verbose;
      signalDecrypt.run(arguments);
      signalDecrypt.signalBackupDecrypt();

      break;
    case 'SignalEncrypt':
      final signalEncrypt = SignalImport();
      signalEncrypt.verbose = verbose;
      signalEncrypt.run(arguments);
      signalEncrypt.signalBackupEncrypt();

      break;
    default:
      print('Invalid argument --command=$command');
  }
}
