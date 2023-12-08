# WhatApp export files

Always start by creating a [Signal](docs/Signal.md) backup.

1. Generate WhatApp export files on Android

   ```text
    WhatApp -> Chat -> 3 dotted menu -> more -> Export chat
   ```

   Do this for every chat you wish to import.

2. Transfer the files to your computer.

   WhatsApp exports will be named eg: WhatsApp Chat with (User Screen Name).txt
   Put all of them into the working folder created like [here](docs/Signal.md).

3. Rename exports

   Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.
   At this point you can also merge files into one, if a user had multiple WhatsApp identities.

   All WhatsApp export files must be renamed like:  
   contactPhoneNumber-ThereScreenName.txt

   eg: +49123456789-Max ExampleName.txt

   You can look inside the file to copy the exact name from there.

4. Run MoveToSignal in terminal

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportWhatsApp
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --whatsappExports=./whatsapp \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportWhatsApp
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --whatsappExports=./whatsapp \
   --verbose
   ```

   Once done, a new Signal backup file is created, like: signal-signal-YYYY-MM-DD-HH-mm-ss.backup (new timestamp)

5. Follow the "After importing all messages" steps from [Signal](docs/Signal.md)
