import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../global/cipher.dart';
import '../models/console_state.dart';
import '../models/crib_match.dart';
import '../pages/analyze/analyze_state.dart';
import '../services/crib.dart';

Future<void> toolFindCribs(BuildContext context) async {
  final consoleState = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final cipher = GetIt.I<Cipher>().raw_cipher.join().replaceAll(RegExp(r'[%$&]'), '').replaceAll('.', '-').replaceAll(' ', '-');

  final words = cipher.split('-').toList();

  words.removeWhere((element) => element.length <= 3);

  consoleState.write_to_console('Total words: ${words.length}');

  final settings = GetIt.instance.get<AnalyzeState>().cribSettings;

  final results = <String, List<CribMatch>>{};

  for (final word in words) {
    final cribber = Crib(settings, word);

    await cribber.start_crib();

    cribber.matches.forEach((element) {
      results[word] ??= [];

      results[word].add(element);
    });
  }

  results.forEach((key, value) {
    consoleState.write_to_console('-> $key ${value.length}');
    value.forEach((element) {
      consoleState.write_to_console('---> ${element.toConsoleString(['cribword', 'shiftlist'])}');
    });
  });
}
