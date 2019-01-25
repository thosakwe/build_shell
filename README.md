# build_shell
[![Pub](https://img.shields.io/pub/v/build_shell.svg)](https://pub.dartlang.org/packages/build_shell)

Builds shell scripts that execute Dart snapshots (from build_vm_compilers).

## Rationale
This package alleviates an inconvenience - at this point in time,
even though you can build `.dill` files via `package:build_vm_compilers`, those
files are placed in the cache, rather than in your actual project. So,
actually running them becomes a little more complex.

This tool just creates shell scripts to let you run them. This way, your script
only has to be compiled once, leading to faster startup times.

## Installation
In your `pubspec.yaml`:

```yaml
dependencies:
  build_shell: ^1.0.0
dev_dependencies:
  build_runner: ^1.0.0
```

## Usage
Simply run:

`pub run build_runner build`.

You'll then see a `.sh` and `.bat` file generated for every Dart script with
a `main` method.