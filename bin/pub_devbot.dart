import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> main() async {
  String botToken = "6715432790:AAGK-WmS_bp1V463JN9sLUty8yqa4vl5yMs";
  final username = (await Telegram(botToken).getMe()).username;

  var teleDart = TeleDart(botToken, Event(username!));
  teleDart.start();

  teleDart.onCommand('start').listen((message) {
    final chatId = message.chat.id;
    final text = 'Salom, bu faqat inline rejimida ishlaydi!';
    teleDart.sendMessage(chatId, text);
  });

  teleDart.onInlineQuery().listen((inlineQuery) async {
    final query = inlineQuery.query;
    final url = Uri.parse('https://pub.dev/api/search?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final packages = data['packages'];

      final results = List<InlineQueryResult>.from(packages.map((package) {
        final packageName = package['package'];
        final score = package['score'] ?? 'N/A';
        final documentationUrl = package['documentation_url'] ?? 'N/A';
        final packageDescription = package['description'] ?? 'N/A';

        final messageText =
            'Package: $packageName\nScore: $score\n\nDescription: $packageDescription\n\nDocumentation: $documentationUrl';

        return InlineQueryResultArticle(
          id: packageName,
          title: packageName,
          inputMessageContent: InputTextMessageContent(
            messageText: messageText,
            parseMode: 'HTML',
          ),
        );
      }));

      teleDart.answerInlineQuery(
        inlineQuery.id,
        results,
      );
    } else {
      print('So\'rov muvaffaqiyatsiz tugabdi: ${response.statusCode}');
    }
  });
}
