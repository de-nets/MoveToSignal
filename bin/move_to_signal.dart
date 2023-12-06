import 'package:move_to_signal/signal_import.dart';
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
    default:
      print('Invalid argument --command=$command');
  }
}
