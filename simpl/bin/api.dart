import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'currencyModel.dart';

class API {
  connectAPI() async {
    var response = await http.get(Uri.parse('https://pokur.su/usd/'));
    if (response.statusCode == 200) {
      List<CurrencyModel> currency = [];
      var document = parse(response.body).getElementsByTagName("tbody").last;
      var listIcon = document.querySelectorAll("img");
      var listCur = document.querySelectorAll("a, a"); // 189talik

      for (var i = 0, j = 0; i < listIcon.length; i++, j += 2) {
        var model = CurrencyModel();
        model.iconPath = listIcon[i].attributes['src'];
        model.name = listCur[j].text;
        model.code = listCur[j].attributes['href']?.replaceAll("/", "");
        model.price = double.parse(
            listCur[j + 1].text.replaceAll(",", ".").replaceAll(" ", ""));
        currency.add(model);
      }

      var mapData = {
        "update": DateTime.now().toString().split(" ")[0],
        "currency": currency.map((e) => e.toJson()).toList()
      };
      var file = File(
          "../src/source.json");
      await file.writeAsString(jsonEncode(mapData));
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};
    }
  }

  readFromFile() async {
    const JsonDecoder decoder = JsonDecoder();
    var file = File(
        "../src/source.json");
    if (file.existsSync()) {
      if (file.lengthSync() == 0) {
        return 0;
      } else {
        final Map<String, dynamic> object =
            decoder.convert(file.readAsStringSync());
        return object;
      }
    } else {
      File("../src/source.json")
          .createSync();
      return 0;
    }
  }
}
