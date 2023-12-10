# Telegram

Always start by creating a [Signal](docs/Signal.md) backup.

1. Create and download a Telegram export Zip via the Telegram website.

2. Run MoveToSignal in terminal for prepare the import

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportTelegram \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --telegramExports=. \
   --telegramJson="path/to/DataExport_YYYY-MM-DD/result.json" \
   --telegramMode=Prepare \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportTelegram \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --telegramExports=. \
   --telegramJson="path/to/DataExport_YYYY-MM-DD/result.json" \
   --telegramMode=Prepare \
   --verbose
   ```

   A new folder named TelegramExportsFolder will be created for the export files.
   Telegram exports will be named eg: Phone number if found or user id-Screen Name.txt

3. Rename exports

   Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.
   At this point you can also merge files into one, if a user had multiple Telegram identities.
   Please delete all files you don't want to import.

   All Telegram export files must be renamed like:  
   contactPhoneNumber-Screen Name.txt

   eg: +49123456789-Max ExampleName.txt

   Only the phone number important for Telegram imports.
   The phone number needs to in international format starting with + and must only contain numbers.

4. Run MoveToSignal in terminal to import the prepared messages

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportTelegram \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --telegramExports=. \
   --telegramMode=Import \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportTelegram \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --telegramExports=. \
   --telegramMode=Import \
   --verbose
   ```

   Once done, a new Signal backup file is created, like: signal-signal-YYYY-MM-DD-HH-mm-ss.backup (new timestamp)

5. Follow the "After importing all messages" steps from [Signal](docs/Signal.md)
