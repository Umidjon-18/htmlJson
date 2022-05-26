import 'api.dart';
import 'dart:io';
import 'package:colorize/colorize.dart';
import 'utils.dart';

class App {
  Utils utils = Utils();
  API api = API();
  currencyConverter() async {
    var currencyTypes = await api.curType();
    // await api.uploadWrite();
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
    print(utils.greenColor('''      
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
    utils.printModel(utils.greenColor('Xizmat turini tanlang ♻️'));
    services(currencyTypes);
  }

  void services(currencyTypes) {
    String valyutaXato = "Valyuta turi xato kiritildi 🚫";
    String serviceType = stdin.readLineSync()!;
    if (serviceType == "1") {
      utils.printModel(utils.greenColor("Valyuta turini kiriting ♻️"));
      String currencyType = stdin.readLineSync()!.toLowerCase();
      if (currencyTypes.containsKey(currencyType)) {
        utils.clear();
        utils.printModel(utils.greenColor(
            "1 USD ${currencyTypes[currencyType]} $currencyType ✅"));
        serviceView(currencyTypes);
      } else {
        utils
            .printModel(utils.redColor("$valyutaXato \n${currencyTypes.keys}"));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "2") {
      utils.printModel(utils
          .greenColor("Valyuta miqdorini va turini probel bilan kiriting ♻️"));
      var amountCur = stdin.readLineSync()!.trim().toLowerCase().split(" ");
      if (!currencyTypes.containsKey(amountCur[1])) {
        utils.printModel(utils.redColor(valyutaXato));
        serviceView(currencyTypes);
      }
      utils.clear();
      utils.printModel(utils.greenColor(
          "${amountCur[0]} ${amountCur[1]}ining USDdagi qiymati ${(double.parse(amountCur[0]) / currencyTypes[amountCur[1]]).toStringAsFixed(3)} \$  ✅"));
      serviceView(currencyTypes);
    } else if (serviceType == "3") {
      utils.printModel(
          utils.greenColor("Valyuta turlarini probel bilan kiriting ♻️"));
      List<String> valyutalar =
          stdin.readLineSync()!.trim().toLowerCase().split(" ");
      if (currencyTypes.containsKey(valyutalar[0])) {
        if (currencyTypes.containsKey(valyutalar[1])) {
          utils.clear();
          utils.printModel(utils.greenColor(
              "${valyutalar[0]} ning ${valyutalar[1]} ga nisbati ${(currencyTypes[valyutalar[1]] / currencyTypes[valyutalar[0]]).toStringAsFixed(3)}  ✅"));
          serviceView(currencyTypes);
        } else {
          utils.printModel(utils.redColor(valyutaXato));
          serviceView(currencyTypes);
        }
      } else {
        utils.printModel(utils.redColor(valyutaXato));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "4") {
      utils.printModel(utils.greenColor("Birinchi valyuta turini kiring"));
      var valyutaBir = stdin.readLineSync()!.toLowerCase();
      if (currencyTypes.containsKey(valyutaBir)) {
        utils.printModel(utils.greenColor("Ikkinchi valyuta turini kiriting"));
        var valyutaIkki = stdin.readLineSync()!.toLowerCase();
        if (currencyTypes.containsKey(valyutaIkki)) {
          utils.printModel(
              utils.greenColor("Birinchi valyuta qiymatini kiriting"));
          double amount = double.parse(stdin.readLineSync()!);
          utils.printModel(utils.greenColor(
              "$amount $valyutaBir ${(currencyTypes[valyutaIkki] / currencyTypes[valyutaBir] * amount).toStringAsFixed(2)} $valyutaIkki ga teng ✅"));
          serviceView(currencyTypes);
        } else {
          utils.printModel(utils.redColor(valyutaXato));
          serviceView(currencyTypes);
        }
      } else {
        utils.printModel(utils.redColor(valyutaXato));
        serviceView(currencyTypes);
      }
    } else if (serviceType == "5") {
      utils.clear();
      exit(0);
    } else {
      utils.printModel(utils.redColor(valyutaXato));
      serviceView(currencyTypes);
    }
  }
}
