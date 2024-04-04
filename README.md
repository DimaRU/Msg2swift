[![Swift](https://img.shields.io/badge/Swift-5.8+-orange)](https://img.shields.io/badge/Swift-5-DE5D43)
[![Platforms](https://img.shields.io/badge/Platforms-all-sucess)](https://img.shields.io/badge/Platforms-all-sucess)
[![CI/CD](https://github.com/DimaRU/Msg2swift/actions/workflows/test.yml/badge.svg)](https://github.com/DimaRU/Msg2swift/actions/workflows/test.yml)

# Msg2swift - Generate Swift models for ROS message and service files.


## Description

Msg2swift help you generate swift models from ROS .msg files. Intended for use with [CDRCodable](https://github.com/DimaRU/CDRCodable).  
In particular Msg2swift generates proper CodableKeys for encoding and decoding fixed-size arrays.


## Installation for use with command line

#### Homebrew

Run the following command to install using [Homebrew](https://brew.sh/):

```console
brew install DimaRU/formulae/msg2swift
```

#### Swift package manager command plugin

When you add [CDRCodable](https://github.com/DimaRU/CDRCodable) dependency to your project:

```swift
.package(url: "https://github.com/DimaRU/CDRCodable", from: "1.0.0")
```
you may use msg2swift SPM command line plugin:

```console
swift package plugin --allow-writing-to-package-directory msg2swift ../../msg/BatteryState.msg -o model
```


## Command line USAGE

```
USAGE: msg2swift [<options>] <file> ...

ARGUMENTS:
  <file>                  .msg or .srv file(s) to convert.

OPTIONS:
  --let/--var             Use var or let for model properties. (default: --let)
  --struct/--class        Struct or class declaration. (default: --struct)
  --codable/--encodable/--decodable
                          Model declaration protocol. (default: --codable)
  --snake-case/--no-snake-case
                          Convert property names from "snake_case" to
                          "camelCase" (default: --snake-case)
  -c, --compact           Compact generated code.
        Strip all comments and remove empty lines.
  --detect-enum/--no-detect-enum
                          Detect enums. (default: --detect-enum)
        Detect and group constants into Swift enum.
  -n, --name <name>       Object name.
        By default file name used.
  -o, --output-directory <path>
                          The output path for generated files.
        By default generated files written to the current directory.
  -s, --silent            Don't print processed file names.
  --version               Show the version.
  -h, --help              Show help information.
```

## Build

Use swift package manager for build.

```console
https://github.com/DimaRU/Msg2swift.git
cd Msg2swift
swift build
```

