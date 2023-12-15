# SMS

Always start by creating a [Signal](docs/Signal.md) backup.

1. Create SMS backup with [SMS Backup & Restore](https://play.google.com/store/apps/details?id=com.riteshsahu.SMSBackupRestore&pli=1) and copy the sms-(timestamp).xml to the working folder.

2. Run MoveToSignal in terminal for prepare the import

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportSms \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --smsXml="path/to/sms-(timestamp).xml" \
   --smsExports=. \
   --smsMode=Prepare \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportSms \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --smsXml="path/to/sms-(timestamp).xml" \
   --smsExports=. \
   --smsMode=Prepare \
   --verbose
   ```

   A new folder named SmsExportsFolder will be created for the export files.
   SMS exports will be named eg: +4912345678-(Screen name if found).txt

3. Rename exports

   Please review the all .txt files and make sure to file names start with the contact phone number the user uses with Signal.
   At this point you can also merge files into one, if a user had multiple SMS identities.
   Please delete all files you don't want to import.

   All SMS export files must be renamed like:  
   contactPhoneNumber-Screen Name.txt

   eg: +49123456789-Max ExampleName.txt

   Only the phone number important for SMS imports.
   The phone number needs to in international format starting with + and must only contain numbers.

4. Run MoveToSignal in terminal to import the prepared messages

   Mac arm64 binary

   ```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=ImportSms \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --smsExports=. \
   --smsMode=Import \
   --verbose
   ```

   From source

   ```bash
   cd path/to/working/folder/

   dart run path/to/MoveToSignal/bin/move_to_signal.dart \
   --command=ImportSms \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --smsExports=. \
   --smsMode=Import \
   --verbose
   ```

   Once done, a new Signal backup file is created, like: signal-signal-YYYY-MM-DD-HH-mm-ss.backup (new timestamp)

5. Follow the "After importing all messages" steps from [Signal](docs/Signal.md)
