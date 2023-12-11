# Available commands

```text
--verbose
    Show detailed progress

--command=
    [ImportTelegram] For Telegram exports
    [ImportWhatsAppDb] For WhatsApp db import (needs decrypted db with wa-crypt-tools)
    [ImportWhatsAppExports] For WhatsApp exports (default)
    [SignalDecrypt] Just to decrypt Signal backup file
    [SignalEncrypt] Just to encrypt Signal backup file

--signalBackup=
    Path to Signal backup file

--signalBackupKey=
    Signal 30 digit backup passphrase like 123451234512345123451234512345

--signalBackupNoDecrypt
    Don't decrypt Signal backup, useful when importing messages from multiple sources. (false by default)

--signalBackupNoEncrypt
    Don't encrypt Signal backup, useful when importing messages from multiple sources. (false by default)

--signalPhoneNumber=
    Your Signal account phone number

--telegramExports=
    Path where to create the folder TelegramExportsFolder to write the Telegram export files into.

--telegramJson=
    Path to the Telegram export json file

--telegramMode=
    [Prepare] Prepare the import by extracting all conversations from telegramJson into separate files to review. (default)
    [Import] Imports the files from step [Prepare] into the Signal database.

--whatsAppDb=
    Path to the WhatsApp msgstore.db file

--whatsAppExports=
    [ImportWhatsAppDb] Path where the WhatsApp .txt file are written
    [ImportWhatsAppExports] Path to the WhatsApp export .txt files

--whatsAppMode=
    [Prepare] Prepare the import by extracting all conversations from msgstore.db into separate files to review. (default)
    [Import] Imports the files from step [Prepare] into the Signal database.
```
