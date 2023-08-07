import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final getDataCommandeCuisineFuture =
    ChangeNotifierProvider<GetDataCommandeCuisineFuture>(
        (ref) => GetDataCommandeCuisineFuture());

class GetDataCommandeCuisineFuture extends ChangeNotifier {
  List<CommandeCuisine> listCommandeWaited = [];
  List<CommandeCuisine> listCommandeTraitement = [];
  List<CommandeCuisine> listCommandeDone = [];
  List<CommandeCuisine> listCommandePaid = [];

  GetDataCommandeCuisineFuture() {
    getData();
  }

  Future getData() async {
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    String adressUrl = prefs.getString('ipport').toString();
    var restaurantid = prefs.getString('idRestaurant');*/
    try {
      http.Response response = await http.get(
        Uri.parse('http://13.39.81.126:4004/api/orders/fetch/all'),
        headers: <String, String>{
          'Context-Type': 'application/json;charSet=UTF-8',
          //'Authorization': 'Bearer $token ',
        },
      );

      print(response.statusCode);
      print('getCommande**************************************************');
      //print("Liste des commandes ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (int i = 0; i < data.length; i++) {
          if (data[i]['deletedAt'] == null) {
            if (data[i]['status'] == 'WAITED') {
              listCommandeWaited.add(CommandeCuisine.fromJson(data[i]));
            } else if (data[i]['status'] == 'TREATMENT') {
              listCommandeTraitement.add(CommandeCuisine.fromJson(data[i]));
            } else if (data[i]['status'] == 'PAID') {
              listCommandePaid.add(CommandeCuisine.fromJson(data[i]));
            } else {
              listCommandeDone.add(CommandeCuisine.fromJson(data[i]));
            }
          }
        }
        for (int i = 0; i < listCommandeWaited.length; i++) {
          for (int j = 0; j < listCommandeWaited[i].menus!.length; j++) {
            for (int s = 0;
                s < listCommandeWaited[i].menus![j].products!.length;
                s++) {
              if (listCommandeWaited[i]
                      .menus![j]
                      .products![s]
                      .category!
                      .title !=
                  'Sodas') {
                listCommandeWaited[i]
                    .products!
                    .add(listCommandeWaited[i].menus![j].products![s]);
              }
            }
          }
        }
        for (int i = 0; i < listCommandeTraitement.length; i++) {
          for (int j = 0; j < listCommandeTraitement[i].menus!.length; j++) {
            for (int s = 0;
                s < listCommandeTraitement[i].menus![j].products!.length;
                s++) {
              if (listCommandeTraitement[i]
                      .menus![j]
                      .products![s]
                      .category!
                      .title !=
                  'Sodas') {
                listCommandeTraitement[i]
                    .products!
                    .add(listCommandeTraitement[i].menus![j].products![s]);
              }
            }
          }
        }
      } else {
        return Future.error(" server erreur");
      }
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }
}

class CommandeCuisine {
  String? sId;
  Null orderTitle;
  bool? isTracking;
  List<Menus>? menus;
  List<Products>? products;
  String? status;
  Null deletedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  CommandeCuisine(
      {this.sId,
      this.orderTitle,
      this.isTracking,
      this.menus,
      this.products,
      this.status,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.iV});

  CommandeCuisine.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    orderTitle = json['order_title'];
    isTracking = json['is_tracking'];
    if (json['menus'] != null) {
      menus = <Menus>[];
      json['menus'].forEach((v) {
        menus!.add(new Menus.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    status = json['status'];
    deletedAt = json['deletedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['order_title'] = this.orderTitle;
    data['is_tracking'] = this.isTracking;
    if (this.menus != null) {
      data['menus'] = this.menus!.map((v) => v.toJson()).toList();
    }
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['deletedAt'] = this.deletedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Products {
  Recette? recette;
  String? sId;
  String? productName;
  int? price;
  Category? category;
  bool? promotion;
  String? devise;
  int? liked;
  int? likedPersonCount;

  Products(
      {this.recette,
      this.sId,
      this.productName,
      this.price,
      this.category,
      this.promotion,
      this.devise,
      this.liked,
      this.likedPersonCount});

  Products.fromJson(Map<String, dynamic> json) {
    recette =
        json['recette'] != null ? new Recette.fromJson(json['recette']) : null;
    sId = json['_id'];
    productName = json['productName'];
    price = json['price'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    promotion = json['promotion'];
    devise = json['devise'];
    liked = json['liked'];
    likedPersonCount = json['likedPersonCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recette != null) {
      data['recette'] = this.recette!.toJson();
    }
    data['_id'] = this.sId;
    data['productName'] = this.productName;
    data['price'] = this.price;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['promotion'] = this.promotion;
    data['devise'] = this.devise;
    data['liked'] = this.liked;
    data['likedPersonCount'] = this.likedPersonCount;
    return data;
  }
}

class Menus {
  String? sId;
  String? menuTitle;

  int? price;
  String? devise;
  List<Products>? products;
  String? sCreator;
  String? deScription;
  String? image;
  Null deletedAt;
  String? description;

  Menus(
      {this.sId,
      this.menuTitle,
      this.price,
      this.devise,
      this.products,
      this.sCreator,
      this.deScription,
      this.image,
      this.deletedAt,
      this.description});

  Menus.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    menuTitle = json['menu_title'];

    price = json['price'];
    devise = json['devise'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    sCreator = json['_creator'];
    deScription = json['de scription'];
    image = json['image'];
    deletedAt = json['deletedAt'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['menu_title'] = this.menuTitle;

    data['price'] = this.price;
    data['devise'] = this.devise;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['_creator'] = this.sCreator;
    data['de scription'] = this.deScription;
    data['image'] = this.image;
    data['deletedAt'] = this.deletedAt;
    data['description'] = this.description;
    return data;
  }
}

class Recette {
  String? sId;
  String? title;
  String? image;
  String? description;
  List<Engredients>? engredients;
  Null? deletedAt;

  Recette(
      {this.sId,
      this.title,
      this.image,
      this.description,
      this.engredients,
      this.deletedAt});

  Recette.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    if (json['engredients'] != null) {
      engredients = <Engredients>[];
      json['engredients'].forEach((v) {
        engredients!.add(new Engredients.fromJson(v));
      });
    }
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['image'] = this.image;
    data['description'] = this.description;
    if (this.engredients != null) {
      data['engredients'] = this.engredients!.map((v) => v.toJson()).toList();
    }
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}

class Engredients {
  String? material;
  String? sId;

  Engredients({this.material, this.sId});

  Engredients.fromJson(Map<String, dynamic> json) {
    material = json['material'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['material'] = this.material;
    data['_id'] = this.sId;
    return data;
  }
}

class Category {
  String? sId;
  String? title;

  Category({this.sId, this.title});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    return data;
  }
}
