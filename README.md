# MoveToSignal

Import messages from other apps like Telegram or WhatsApp to Signal.

## Caveats

- Only tested on Android
- No group text support
- The commands were run on macOS

## Prerequisites

See: [Install](docs/Install.md)

## Prepare Signal for import

See: [Signal](docs/Signal.md)

## Instructions

Import messages from:

- [Telegram](docs/Telegram.md)
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

## Known issues

### Language based date time format in Whatsapp exports

Whatsapp exports have language based time format in export file and for Android without seconds. In my case 01/12/2023, 23:59  
The new WhatsApp macOS App has a more usable format [01.12.23, 23:59:42] for the same message as Android, but in my case only loads the last 3 years of chat history.

Please open an issue with a small anonymized sample export and your device language. Or better open a PR with a fix. :)

## Sponsor this project

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/movetosignal/5)

You might also consider helping out the Signal Foundation here: <https://support.signal.org/hc/en-us/articles/360007319831-How-can-I-contribute-to-Signal->
