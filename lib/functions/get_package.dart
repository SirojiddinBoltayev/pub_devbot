import 'dart:convert';
import 'dart:math';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:http/http.dart' as http;

Future<String> getPackage({
  required packagesName,
}) async {
  final urlPackage = Uri.parse('https://pub.dev/api/packages/$packagesName');
  final responsePackage = await http.get(urlPackage);

  if (responsePackage.statusCode == 200) {
    final dataPackages = json.decode(responsePackage.body);
    final packagesPackage = dataPackages;
    log(packagesPackage);
    // packagesPackage.map((data) {
    //   // Modify this part to transform the data as needed
    //   // Instead of printing, return the transformed data
    //   return data;
    // }).forEach((transformedData) {
    //   print(transformedData); // Now you can print the transformed data
    // });
    // print(packagesPackage);
    return packagesPackage;
  } else {
    return "Ma'lumotni olib bo'lmadi";
  }
}
