import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
class API {
  // Kerakli elementlarni olish uchun Listlarni yaratib olamiz
  final _flagURLs = [];
  final _curAmounts = [];
  final _curFullNames = [];
  final _curNames = [];
  connectAPI() async {
    var response = await http.get(Uri.parse('https://pokur.su/usd/'));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final page = document.querySelectorAll("tbody").last.outerHtml;

      // cutter funksiyasi orqali kerakli qismlarni qirqib listlarga qo'shib olamiz
      cutter(page, '<img src="')
          .forEach(((element) => _flagURLs.add(element.split('"')[0])));
      cutter(page, '<td><a href="/').forEach(((element) =>
          _curFullNames.add(element.split('>')[1].split('<')[0])));
      cutter(page, '<a href="/usd/').forEach(((element) {
        _curAmounts.add(element
            .split('>')[1]
            .split('<')[0]
            .replaceAll(RegExp(r' '), '')
            .replaceAll(RegExp(r','), '.'));
        _curNames.add(element.split('>')[0].split('/')[0]);
      }));

      // Listning ortiqcha qismini o'chirib tashlaymiz
      _flagURLs.removeAt(0);
      _curAmounts.removeAt(0);
      _curAmounts.removeAt(_curAmounts.length - 2);
      _curNames.removeAt(0);
      _curNames.removeAt(_curNames.length - 2);
      _curFullNames.removeAt(0);
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};
    }
  }

  List cutter(String page, String cut) {
    return page.split(cut);
  }

  Future<void> uploadWrite() async {
    await connectAPI();
    var jsonFile = File('../src/source.json');
    var jsonData = [];
    for (int i = 0; i < 15; i++) {
      var flagResponse =
          await http.get(Uri.parse("https://pokur.su/${_flagURLs[i]}"));
      var flag = File('../src/flages/${_curNames[i]}.svg');
      await flag.writeAsString(flagResponse.body);
      Map formData = {
        "curName": _curNames[i],
        "curFullName": _curFullNames[i],
        "curAmount": double.parse(_curAmounts[i]),
        "flagPath": flag.path
      };
      jsonData.add(formData);
    }
    await jsonFile.writeAsString(json.encode(jsonData));
    print("Data has been wrote to the file and images has been uploaded");
  }

  curType() async {
    await connectAPI();
    Map result = {};
    for (int i = 0; i < _curNames.length; i++) {
      Map formData = {_curNames[i]: double.parse(_curAmounts[i])};
      result.addAll(formData);
    }
    return result;
  }
}
