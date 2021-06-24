import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/ionicons.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/screens/productPage.dart';
import 'package:littardo/screens/products_list.dart';
import 'package:littardo/widgets/star_rating.dart';

class TrendingItem extends StatelessWidget {
  final Product product;
  final List<Color> gradientColors;
  final Function updateWishList;

  TrendingItem({this.product, this.gradientColors, this.updateWishList});

  @override
  Widget build(BuildContext context) {
    double trendCardWidth = 140;
    print(product.isWishlisted);

    return GestureDetector(
      child: Stack(
        children: <Widget>[
          Container(
            width: trendCardWidth,
            child: Card(
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Spacer(),
                        InkWell(
                          onTap: updateWishList,
                          child: Icon(
                            Ionicons.getIconData(product.isWishlisted == "1"
                                ? "ios-heart"
                                : "ios-heart-empty"),
                            color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                    _productImage(),
                    _productDetails()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        if (product.type != null && product.type == "brand") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductList(
                  id: product.id, name: product.name, type: "brand", query: ""),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductPage(
                product: product,
              ),
            ),
          );
        }
      },
    );
  }

  _productImage() {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            width: 75,
            height: 75,
            child: Image.network(
              product.icon,
              errorBuilder: (context, _, __) {
                return Image.asset("assets/littardo_logo.jpg");
              },
            ),
          ),
        )
      ],
    );
  }

  _productDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   product.company,
        //   style: TextStyle(fontSize: 12, color: Color(0XFFb1bdef)),
        // ),
        Text(
          product.name,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        product.rating != null
            ? StarRating(rating: product.rating, size: 10)
            : SizedBox(),
        product.price != null
            ? FittedBox(
                child: Row(
                  children: <Widget>[
                    Text("\u20b9 " +
                                      product.price,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                    SizedBox(
                      width: 6,
                    ),
                    if (product.price != product.originalPrice)
                      Text(
                        "\u20b9 " +
                                      product.originalPrice,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough),
                      )
                  ],
                ),
              )
            : SizedBox()
      ],
    );
  }
}
