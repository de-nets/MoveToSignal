# WhatApp DB

Always start by creating a [Signal](docs/Signal.md) backup.

1. Create WhatsApp backup, decrypt the msgstore.db.crypt15 with [wa-crypt-tools](https://github.com/ElDavoo/wa-crypt-tools) and copy the msgstore.db to the working folder.

2. Run MoveToSignal in terminal for prepare the import

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportWhatsAppDb \
   --whatsAppDb="path/to/msgstore.db" \
   --whatsAppExports=. \
   --whatsAppMode=Prepare \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportWhatsAppDb \
   --whatsAppDb="path/to/msgstore.db" \
   --whatsAppExports=. \
   --whatsAppMode=Prepare \
   --verbose
   ```

   A new folder named WhatsAppExportsFolder will be created for the export files.
   WhatsApp exports will be named eg: +4912345678-.txt

3. Rename exports

   Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.
   At this point you can also merge files into one, if a user had multiple WhatsApp identities.
   Please delete all files you don't want to import.

   All WhatsApp export files must be renamed like:  
   contactPhoneNumber-ThereScreenName.txt

   eg: +49123456789-Max ExampleName.txt

   Only the phone number important for WhatsApp DB imports.
   The phone number needs to in international format starting with + and must only contain numbers.

4. Run MoveToSignal in terminal to import the prepared messages

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportWhatsAppDb \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --whatsAppExports=. \
   --whatsAppMode=Import \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportWhatsAppDb \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --whatsAppExports=. \
   --whatsAppMode=Import \
   --verbose
   ```

   Once done, a new Signal backup file is created, like: signal-signal-YYYY-MM-DD-HH-mm-ss.backup (new timestamp)

5. Follow the "After importing all messages" steps from [Signal](docs/Signal.md)
