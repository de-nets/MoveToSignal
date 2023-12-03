import 'package:move_to_signal/source_whats_app.dart';

void main(List<String> arguments) {
  String importSource = 'WhatsApp';

  // Read all arguments
  for (final argument in arguments) {
    if (argument.startsWith('--importSource=')) {
      importSource = argument.split('=').last;
    }
  }

  switch (importSource) {
    case 'WhatsApp':
      final whatsAppImport = SourceWhatsApp();
      whatsAppImport.run(arguments);

      break;
    default:
      print('Invalid argument --importSource');
  }
}
