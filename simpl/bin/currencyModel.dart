class CurrencyModel {
  String? code;
  double? price;
  String? name;
  String? iconPath;

  CurrencyModel({this.code, this.price, this.name, this.iconPath});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    price = json['price'];
    name = json['name'];
    iconPath = json['iconPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['price'] = price;
    data['name'] = name;
    data['iconPath'] = iconPath;
    return data;
  }
}