import 'dart:convert';
import 'dart:io';
import 'package:colorize/colorize.dart';
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
    for (int i = 0; i < _curNames.length; i++) {
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

class App {
  currencyConverter() async {
    var currencyTypes = await API().curType();
    // await API().uploadWrite();
    var date = DateTime.now();
    print(Colorize('''
------------------------------
|       Valyuta kursi        |
|                            |
|   AQSH dollari hisobida    |
|    $date                   |
------------------------------
''').green());
    serviceView(currencyTypes);
  }

  void serviceView(currencyTypes) {
    print(greenColor('''      
--------------------------------------------------
|       Xizmat turlari                           |
|                                                |
| 1) 1 USDning boshqa valyutadagi qiymati        |
|                                                |
| 2) Valyutani USDda hisoblash                   |
|                                                |
| 3) Valyutaning valyutaga nisbati               |
|                                                |
| 4) Valyutaning boshqa valyutadagi qiymati      |
|                                                |
| 5) Chiqish                                     |
--------------------------------------------------'''));
    printModel(greenColor('Xizmat turini tanlang ♻️'));
    services(currencyTypes);
  }

  void services(currencyTypes) {
    String valyutaXato = "Valyuta turi xato kiritildi 🚫";
    String serviceType = stdin.readLineSync()!;
    if (serviceType == "1") {
      printModel(greenColor("Valyuta turini kiriting ♻️"));
      String currencyType = stdin.readLineSync()!.toLowerCase();
      if (currencyTypes.containsKey(currencyType)) {
        clear();
        printModel(
            greenColor("1 USD ${currencyTypes[currencyType]} $currencyType ✅"));
        serviceView(currencyTypes);
      } else {
        printModel(redColor(
            "Valyuta turi xato kiritildi ! 🚫 \n${currencyTypes.keys}"));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "2") {
      printModel(
          greenColor("Valyuta miqdorini va turini probel bilan kiriting ♻️"));
      var amountCur = stdin.readLineSync()!.trim().toLowerCase().split(" ");
      if (!currencyTypes.containsKey(amountCur[1])) {
        printModel(redColor("Valyuta turi xato kiritildi 🚫"));
        serviceView(currencyTypes);
      }
      clear();
      printModel(greenColor(
          "${amountCur[0]} ${amountCur[1]}ining USDdagi qiymati ${(double.parse(amountCur[0]) / currencyTypes[amountCur[1]]).toStringAsFixed(3)} \$  ✅"));
      serviceView(currencyTypes);
    } else if (serviceType == "3") {
      printModel(greenColor("Valyuta turlarini probel bilan kiriting ♻️"));
      List<String> valyutalar =
          stdin.readLineSync()!.trim().toLowerCase().split(" ");
      if (currencyTypes.containsKey(valyutalar[0])) {
        if (currencyTypes.containsKey(valyutalar[1])) {
          clear();
          printModel(greenColor(
              "${valyutalar[0]} ning ${valyutalar[1]} ga nisbati ${(currencyTypes[valyutalar[1]] / currencyTypes[valyutalar[0]]).toStringAsFixed(3)}  ✅"));
          serviceView(currencyTypes);
        } else {
          printModel(redColor("Ikkinchi valyuta turi xato kiritildi!  🚫"));
          serviceView(currencyTypes);
        }
      } else {
        printModel(redColor("Birinchi valyuta turi xato kiritildi!  🚫"));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "4") {
      printModel(greenColor("Birinchi valyuta turini kiring"));
      var valyutaBir = stdin.readLineSync()!.toLowerCase();
      if (currencyTypes.containsKey(valyutaBir)) {
        printModel(greenColor("Ikkinchi valyuta turini kiriting"));
        var valyutaIkki = stdin.readLineSync()!.toLowerCase();
        if (currencyTypes.containsKey(valyutaIkki)) {
          printModel(greenColor("Birinchi valyuta qiymatini kiriting"));
          double amount = double.parse(stdin.readLineSync()!);
          printModel(greenColor(
              "$amount $valyutaBir ${(currencyTypes[valyutaIkki] / currencyTypes[valyutaBir] * amount).toStringAsFixed(2)} $valyutaIkki ga teng ✅"));
          serviceView(currencyTypes);
        } else {
          printModel(redColor("Valyuta turi xato kiritildi!  🚫"));
          serviceView(currencyTypes);
        }
      } else {
        printModel(redColor("Valyuta turi xato kiritildi!  🚫"));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "5") {
      clear();
      exit(0);
    } else {
      printModel(redColor("Xizmat turi noto'g'ri kiritildi  🚫"));
      serviceView(currencyTypes);
    }
  }

  void printModel(Colorize text) {
    print(greenColor(
        '''-----------------------------------------------------------------------
|                                                                     |'''));
    print("  $text");
    print(greenColor(
        '''|                                                                     |
-----------------------------------------------------------------------'''));
  }

  Colorize greenColor(String text) {
    return Colorize(text).green();
  }

  Colorize redColor(String text) {
    return Colorize(text).red();
  }

  clear() {
    print(Process.runSync("clear", [], runInShell: true).stdout);
  }
}
