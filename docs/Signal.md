# Signal

## What to prepare in Signal before importing

- Before you begin make sure you:
  - backup Signal **before** you begin
  - have written down the 30 digit backup code
  - still have your phone number for identity verification
  - still remember your numerical Signal Pin
- Make sure you have an open Signal tread for every contact you wish to import messages to. Just draft and delete a text should do the trick.

## Create working folder like this

```text
--- user/signal
|--- whatsapp     // directory for all whatsapp export files
|- signal.backup  // Signal backup file
```

## Generate a Signal backup file on Android

```text
Signal -> Settings -> Chats -> Backups -> Local Backup
```

Signal file will be named eg: signal-2023-12-03-12-00-00.backup

Transfer the file to your computer to the working folder created before.

## Import messages from more than one source

In this case you should decrypt before running the import command.

```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=SignalDecrypt \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --verbose
```

Followed by the prepare and import commands and add

```bash
--signalBackupNoDecrypt --signalBackupNoEncrypt
```

to them.

Once you are done importing create a new encrypted backup file.

```bash
   cd path/to/working/folder/

   path/to/MoveToSignal/move_to_signal_Darwin_arm64 \
   --command=SignalEncrypt \
   --signalBackup=./signal-YYYY-MM-DD-HH-mm-ss.backup \
   --signalBackupKey=123451234512345123451234512345 \
   --signalPhoneNumber=+49123456789 \
   --verbose
```

This will create a new backup like: signal-signal-YYYY-MM-DD-HH-mm-ss.backup (new timestamp)

## After importing all messages

1. Copy the new Signal backup to your phone.

2. Delete and reinstall the Signal app or if you know how delete all app storage.

3. Restore Signal by using the new backup file.
