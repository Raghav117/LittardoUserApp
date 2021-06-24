import 'dart:convert';

List<Product> welcomeFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String welcomeToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product(
      {this.id,
      this.name,
      this.icon,
      this.rating,
      this.isWishlisted,
      this.price,
      this.originalPrice,
      this.description,
      this.remainingQuantity,
      this.currentStock,
      this.shippingCost,
      this.discount,
      this.photos,
      this.type});

  String id;
  String name;
  String icon;
  double rating;
  String isWishlisted;
  String originalPrice;
  String description;
  int remainingQuantity;
  String price;
  String currentStock;
  String shippingCost;
  String discount;
  String type;
  List photos;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        rating: json["rating"],
        isWishlisted: json["isWishlisted"],
        originalPrice: json["originalPrice"],
        description: json["description"],
        price: json["price"],
        remainingQuantity: json["remainingQuantity"],
        currentStock: json["current_stock"],
        shippingCost: json["shipping_cost"],
        discount: json["discount"],
        type: json["type"],
        photos: List<String>.from(json["photos"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "rating": rating,
        "isWishlisted": isWishlisted,
        "originalPrice": originalPrice,
        "description": description,
        "price": price,
        "remainingQuantity": remainingQuantity,
        "current_stock": currentStock,
        "shipping_cost": shippingCost,
        "discount": discount,
        "type": type,
        "photos": List<dynamic>.from(photos.map((x) => x)),
      };
}
