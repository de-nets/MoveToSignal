# MoveToSignal

Import messages from other apps like WhatsApp to Signal.

## Caveats

* Only tested on Android
* No group text support
* The commands below were run on macOS
* Before you begin make sure you:
  * backup Signal before you begin
  * have written down the 30 digit backup code
  * still have your phone number for identity verification
  * still remember your numerical Signal Pin

## Instructions

1. Install [Dart](https://dart.dev/)

2. Download/Clone this git or download arm macOS binary

3. Install [signalbackup-tools](https://github.com/bepaald/signalbackup-tools)

4. Make sure you have an open Signal tread for every contact you wish to import messages to. Just draft and delete a text should do the trick.

5. Generate a Signal backup file on Android

    ```text
    Signal -> Settings -> Chats -> Backups -> Local Backup
    ```

6. Generate WhatApp export files on Android

    ```text
    WhatApp -> Chat -> 3 dotted menu -> more -> Export chat
    ```

    Do this for every chat you wish to import.

7. Transfer the files to your computer.

    Signal file will be named eg: signal-2023-12-03-12-00-00.backup  
    WhatsApp exports will be named eg: WhatsApp Chat with (User Screen Name).txt

8. Rename exports

    WhatApp:

    All WhatsApp export files must be renamed like:  
    contactPhoneNumber-ThereScreenName.txt  

    eg: +49123456789-Max ExampleName.txt  

    You can look inside the file to copy the exact name from there.

9. Create working folder like this

    ```text
    --- user/signal
    |--- whatsapp     // directory for all whatsapp export files
    |- signal.backup  // Signal backup file
    ```

10. Run MoveToSignal in terminal

    Mac arm64 binary

    ```bash
    cd path/to/working/folder/from/step/9

    path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
    --signalBackup=./signal-2023-12-03-12-00-00.backup \
    --signalBackupKey=123451234512345123451234512345 \
    --signalPhoneNumber=+49123456789 \
    --whatsappExports=./whatsapp \
    --verbose
    ```

    From source

    ```bash
    cd path/to/working/folder/from/step/9

    dart run path/to/MoveToSignal/bin/move_to_signal.dart \
    --signalBackup=./signal-2023-12-03-12-00-00.backup \
    --signalBackupKey=123451234512345123451234512345 \
    --signalPhoneNumber=+49123456789 \
    --whatsappExports=./whatsapp \
    --verbose
    ```

    Once done, a new Signal backup file is created.  
    In the example from above  signal-2023-12-03-12-00-00_WAImported.backup  

11. Copy the new Signal backup to your phone.

12. Delete and reinstall the Signal app or if you know how delete all app storage.

13. Restore Signal by using the new backup file.

### Available commands

```text
--verbose
    Show detailed progress

--command=
    [ImportWhatsApp] For WhatsApp exports (default)
    [SignalDecrypt] Just to decrypt Signal backup file
    [SignalEncrypt] Just to encrypt Signal backup file

--signalBackup=
    Path to Signal backup file

--signalBackupKey=
    Signal 30 digit backup passphrase like 123451234512345123451234512345

--signalPhoneNumber=
    Your Signal account phone number

--whatsappExports=
    [WhatsApp] For WhatsApp exports
```

## Build binary from source

```bash
cd path/to/MoveToSignal/

dart compile exe \
bin/move_to_signal.dart \
-o build/move_to_signal_$(uname -s)_$(uname -m)
```

## Known issues

### Language based date time format in Whatsapp exports

Whatsapp exports have language based time format in export file and for Android without seconds. In my case 01/12/2023, 23:59  
The new WhatsApp macOS App has a more usable format [01.12.23, 23:59:42] for the same message as Android, but in my case only loads the last 3 years of chat history.

Please open an issue with a small anonymized sample export and your device language. Or better open a PR with a fix. :)

## Sponsor this project

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/movetosignal/5)

You might also consider helping out the Signal Foundation here: <https://support.signal.org/hc/en-us/articles/360007319831-How-can-I-contribute-to-Signal->
