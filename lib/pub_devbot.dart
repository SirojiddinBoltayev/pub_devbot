import 'dart:io' show Platform;

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> botStart() async {
  final botToken = "6715432790:AAGK-WmS_bp1V463JN9sLUty8yqa4vl5yMs";
  final envVars = Platform.environment;
  final username = (await Telegram(envVars[botToken] ?? "").getMe()).username;

  // TeleDart uses longpoll by default if no update fetcher is specified.
  var teleDart = TeleDart(envVars[botToken] ?? "", Event(username ?? ""));
  teleDart.start();

  teleDart.onCommand('start').listen((message) {
    final chatId = message.chat.id;
    final text = 'Salom, bu botdan xush kelibsiz!';
    teleDart.sendMessage(chatId, text);
  });
}
