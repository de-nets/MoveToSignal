# MoveToSignal

Import messages from other apps like Telegram or WhatsApp to Signal.

## Caveats

- Only tested on Android
- The commands were run on macOS

## Prerequisites

See: [Install](docs/Install.md)

## Prepare Signal for import

See: [Signal](docs/Signal.md)

## Instructions

Import messages from:

- [Telegram](docs/Telegram.md)
- [WhatApp DB](docs/WhatApp_DB.md)
- [WhatApp export](docs/WhatApp_Export.md)

### Available commands

See: [Commands](docs/Commands.md)

## Build binary from source

```bash
cd path/to/MoveToSignal/

dart compile exe \
bin/move_to_signal.dart \
-o build/move_to_signal_$(uname -s)_$(uname -m)
```

## Feature Map

| Name                       | Telegram | WhatApp DB | WhatApp export |
| :------------------------- | :------: | :--------: | :------------: |
| All 1-on-1 text messages   |    ✅    |     ✅     |       ❌       |
| Group chats                |    ❌    |     ❌     |       ❌       |
| Original timestamps        |    ✅    |     ✅     |       ❌       |
| Reactions (emoji)          |    ❌    |     ✅     |       ❌       |
| Media (images/audio/links) |    ❌    |     ❌     |       ❌       |

## Known issues

### Language based date time format in WhatsApp exports

NOTE: This can be avoided by using the [WhatApp DB](docs/WhatApp_DB.md) import.

WhatsApp exports have language based time format in export file and for Android without seconds. In my case 01/12/2023, 23:59  
The new WhatsApp macOS App has a more usable format [01.12.23, 23:59:42] for the same message as Android, but in my case only loads the last 3 years of chat history.

Please open an issue with a small anonymized sample export and your device language. Or better open a PR with a fix. :)

### Missing messages form WhatsApp exports

NOTE: This can be avoided by using the [WhatApp DB](docs/WhatApp_DB.md) import.

If a message was part of a sent image the message won't be in the export.
I opened an issue with WhatsApp, but don't know if this will ever be fixed.

## Sponsor this project

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/movetosignal/5)

You might also consider helping out the Signal Foundation here: <https://support.signal.org/hc/en-us/articles/360007319831-How-can-I-contribute-to-Signal->
