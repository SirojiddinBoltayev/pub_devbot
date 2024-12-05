import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> main() async {
  // Pub.dev bot
  String botToken = "6715432790:AAGK-WmS_bp1V463JN9sLUty8yqa4vl5yMs";

  // Siroj Boltayev bot
  // String botToken = "6330873616:AAE0SoKc93g0VCPrK1rd6UomogLvx31cI4c";
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
    final urlSearch = Uri.parse('https://pub.dev/api/search?q=$query');
    final responseSearch = await http.get(urlSearch);

    if (responseSearch.statusCode == 200) {
      final dataSearch = json.decode(responseSearch.body);
      final packagesSearch = dataSearch['packages'];

      final resultsSearch = await Future.wait(
        packagesSearch.map<Future<InlineQueryResult>>((package) async {
          final packageName = package['package'];

          return InlineQueryResultArticle(
            id: packageName,
            title: packageName,
            inputMessageContent: InputTextMessageContent(
              messageText: await getPackage(
                packageName: packageName,
              ),
              parseMode: 'MARKDOWN',
            ),
          );
        }).toList(),
      );

      teleDart.answerInlineQuery(
        inlineQuery.id,
        resultsSearch.cast<InlineQueryResult>(),
        button: InlineQueryResultsButton(
          text: "Pub.dev dan qidirish",
          webApp: WebAppInfo(url: "https://pub.dev/"),
        ),
      );
    } else {
      print('So\'rov muvaffaqiyatsiz tugabdi: ${responseSearch.statusCode}');
      throw Exception();
    }
  });
}

Future<String> getPackage(
    {required String packageName,
    bool isAll = false,
    bool isDesc = false,
    bool isNameAndVersion = false}) async {
  print(packageName);
  final urlPackage = Uri.parse('https://pub.dev/api/packages/$packageName');
  final responsePackage = await http.get(urlPackage);

  if (responsePackage.statusCode == 200) {
    final dataPackage = json.decode(responsePackage.body);
    // print(dataPackage);
    final latest = dataPackage['latest']["version"];
    final description = dataPackage['latest']["pubspec"]["description"];
    final String installing = "```Flutter\nflutter pub add $packageName\n```";
    if (isAll) {
      return '```$packageName: $latest```\n\n**$description**\n\n```\nflutter pub add $packageName\n```';
    } else if (isNameAndVersion) {
      return '$packageName: $latest';
    } else if (isDesc) {
      return "$description";
    }
    return '```$packageName: $latest```\n\n**$description**\n\n```\nflutter pub add $packageName\n```';

    // return '```$packageName: $latest```\n\n**$description**\n\n```\nflutter pub add $packageName\n```';
  } else {
    return 'Ma\'lumot olishda xatolik yuz berdi: ${responsePackage.statusCode}';
  }
}
