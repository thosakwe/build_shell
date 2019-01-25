import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart';
import 'package:scratch_space/scratch_space.dart';

/// Builds shell scripts.
Builder shellBuilder(_) => const ShellBuilder();

/// Builds shell scripts.
class ShellBuilder implements Builder {
  static final RegExp _ext = RegExp(r'\.vm\.app\.dill');
  static final Resource<ScratchSpace> _resx =
      Resource(() => ScratchSpace(), dispose: (s) => s.delete());

  const ShellBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.vm.app.dill': ['.sh', '.bat']
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var batId =
        AssetId(inputId.package, inputId.path.replaceFirst(_ext, '.bat'));
    var shId = AssetId(inputId.package, inputId.path.replaceFirst(_ext, '.sh'));

    var p = Context(style: Style.posix);
    var winP = Context(style: Style.windows);
    var generatedPath = p.join(
        '.dart_tool', 'build', 'generated', inputId.package, inputId.path);
    var winPath = winP.join(
        '.dart_tool', 'build', 'generated', inputId.package, inputId.path);

    var space = await buildStep.fetchResource(_resx);
    var shFile = space.fileFor(shId);
    await shFile.create(recursive: true);

    await shFile.writeAsString(
        '#!/usr/bin/env bash\ndart "$generatedPath" "\$@"\nexit \$?');

    if (!Platform.isWindows) {
      var result = await Process.run('chmod', ['+x', shFile.absolute.path],
          runInShell: true, stdoutEncoding: utf8, stderrEncoding: utf8);

      if (result.exitCode != 0)
        log.warning('Failed to mark file ${shFile.path} as executable.');
    }

    // Write the sh file
    await space.copyOutput(shId, buildStep);

    // Write the bat file
    await buildStep.writeAsString(batId,
        '@echo off\r\ndart "$winPath" %*\r\nexit /b %errorlevel%'.trim());
  }
}
