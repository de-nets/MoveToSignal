import 'package:move_to_signal/import/signal.dart';
import 'package:move_to_signal/source/telegram.dart';
import 'package:move_to_signal/source/whats_app_export.dart';

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
      final telegramImport = Telegram();
      telegramImport.verbose = verbose;
      telegramImport.run(arguments);

      break;
    case 'ImportWhatsAppExports':
      final whatsAppImport = WhatsAppExport();
      whatsAppImport.verbose = verbose;
      whatsAppImport.run(arguments);

      break;
    case 'SignalDecrypt':
      final signalDecrypt = Signal();
      signalDecrypt.verbose = verbose;
      signalDecrypt.run(arguments);
      signalDecrypt.signalBackupDecrypt();

      break;
    case 'SignalEncrypt':
      final signalEncrypt = Signal();
      signalEncrypt.verbose = verbose;
      signalEncrypt.run(arguments);
      signalEncrypt.signalBackupEncrypt();

      break;
    default:
      print('Invalid argument --command=$command');
  }
}
