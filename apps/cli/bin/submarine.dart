import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:submarine_cli/submarine_cli.dart';

Future<void> main(List<String> arguments) async {
  try {
    await SubmarineCommandRunner().run(arguments);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exitCode = 64;
  } on CliException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
