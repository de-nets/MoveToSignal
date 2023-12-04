import 'package:move_to_signal/source_whats_app.dart';

void main(List<String> arguments) {
  String importSource = 'WhatsApp';
  bool verbose = false;

  // Read all arguments
  for (final argument in arguments) {
    if (argument == '--verbose') {
      verbose = true;
    }
    if (argument.startsWith('--importSource=')) {
      importSource = argument.split('=').last;
    }
  }

  switch (importSource) {
    case 'WhatsApp':
      final whatsAppImport = SourceWhatsApp();
      whatsAppImport.verbose = verbose;
      whatsAppImport.run(arguments);

      break;
    default:
      print('Invalid argument --importSource=$importSource');
  }
}
