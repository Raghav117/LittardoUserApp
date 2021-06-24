import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';

class Filtre extends StatefulWidget {
  final Function(String) productCallBack;

  Filtre({this.productCallBack});

  @override
  _FiltreState createState() => _FiltreState();
}

class _FiltreState extends State<Filtre> {
  double _lowerValue = 1;
  double _upperValue = 50000;
  bool _isDragged = false;
  String selectedCategory = "";
  List subCategoryList = [];
  List subSubCategoryList = [];
  List attributes = [];
  List allColors = [];
  List products = [];
  String sortByValue = "";
  int sortByIndex = 0;
  String selectedColor = "";
  List selectedSizes = [];
  List selectedFabric = [];
  String filterData = "";
  String lastFetchUrl = "";

  List<String> sortByList = [
    "Newest",
    "Oldest",
    "Price low to high",
    "Price high to low",
  ];

  void resetFilter() {
    sortByValue = "";
    sortByIndex = 1;
    selectedSizes = [];
    selectedFabric = [];
    selectedColor = "";
    sortByValue = "";
    setState(() {});
  }

  ///https://littardo-api.xyz/search?
  ///attribute_1[]=L
  ///&attribute_1[]=M
  ///&category=Demo-category-1
  ///&q=
  ///&sort_by=2
  ///&brand=
  ///&seller_id=
  ///&min_price=
  ///&max_price

  void generateFilterData() {
    if (lastFetchUrl.isNotEmpty) {
      if (sortByIndex > 0) {
        lastFetchUrl += "&sort_by=$sortByIndex";
      }
      if (selectedColor.isNotEmpty) {
        lastFetchUrl += "&color=${selectedColor.replaceFirst("#", "%23")}";
      }
      selectedSizes.forEach((size) {
        lastFetchUrl += "&attribute_1[]=$size";
      });
      selectedFabric.forEach((fabric) {
        lastFetchUrl += "&attribute_2[]=$fabric";
      });
      if (_isDragged) {
        lastFetchUrl += "&min_price=$_lowerValue&max_price=$_upperValue";
      }
    }
    print(lastFetchUrl);
    widget.productCallBack(lastFetchUrl);
  }

  @override
  void initState() {
    // print(Provider.of<UserData>(context, listen: false).getcategories);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProducts(
          "category",
          Provider.of<UserData>(context, listen: false)
              .getcategories
              .first["slug"]);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: resetFilter,
                  child: Text(
                    "Reset",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                InkWell(
                  onTap: generateFilterData,
                  child: Text(
                    "Filters",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Wrap(
              children: List.generate(
                Provider.of<UserData>(context, listen: false)
                    .getcategories
                    .length,
                (index) => buildChip(
                    Provider.of<UserData>(context, listen: false)
                        .getcategories[index],
                    Colors.grey.shade400,
                    "sub",
                    Colors.grey.shade600),
              ),
            ),
            subCategoryList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.black26,
                      height: 2,
                    ),
                  )
                : SizedBox(),
            subCategoryList.isNotEmpty
                ? Wrap(
                    children: List.generate(
                      subCategoryList.length,
                      (index) => buildChip(
                        subCategoryList[index],
                        Colors.grey.shade400,
                        "subsub",
                        Colors.grey.shade600,
                      ),
                    ),
                  )
                : SizedBox(),
            subSubCategoryList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.black26,
                      height: 2,
                    ),
                  )
                : SizedBox(),
            subSubCategoryList.isNotEmpty
                ? Wrap(
                    children: List.generate(
                      subSubCategoryList.length,
                      (index) => buildChip(
                        subSubCategoryList[index],
                        Colors.grey.shade400,
                        "A",
                        Colors.grey.shade600,
                      ),
                    ),
                  )
                : SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("SORT BY"),
            ),
            ListView.separated(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  setState(() {
                    sortByValue = sortByList[index];
                    sortByIndex = index + 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 8.0),
                      child: Text(
                        sortByList[index],
                        style: sortByValue == sortByList[index]
                            ? TextStyle(color: Theme.of(context).primaryColor)
                            : TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    sortByValue == sortByList[index]
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              separatorBuilder: (context, index) => Divider(),
              itemCount: sortByList.length,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                color: Colors.black26,
                height: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: Text("PRICE"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("\u20b9 " + '$_lowerValue'),
                  Text("\u20b9 " + '$_upperValue'),
                ],
              ),
            ),
            FlutterSlider(
              tooltip: FlutterSliderTooltip(
                leftPrefix: Icon(
                  Icons.attach_money,
                  size: 19,
                  color: Colors.black45,
                ),
                rightSuffix: Icon(
                  Icons.attach_money,
                  size: 19,
                  color: Colors.black45,
                ),
              ),
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black12,
                  border: Border.all(width: 3, color: Colors.blue),
                ),
                activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.red.withOpacity(0.5)),
              ),
              values: [1, 45000],
              rangeSlider: true,
              max: 50000,
              min: 0,
              onDragging: (handlerIndex, lowerValue, upperValue) {
                _lowerValue = lowerValue;
                _upperValue = upperValue;
                _isDragged = true;
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                color: Colors.black26,
                height: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: Text("FILTER BY COLOR"),
            ),
            Row(
              children: List.generate(
                allColors.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedColor = allColors[index];
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: CircleAvatar(
                            maxRadius: 18,
                            backgroundColor: Color(int.parse("0xFF" +
                                allColors[index]
                                    .toString()
                                    .replaceAll("#", ""))),
                          ),
                        ),
                        selectedColor == allColors[index]
                            ? Icon(
                                Icons.check,
                                color: Colors.black45,
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                color: Colors.black26,
                height: 2,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                attributes.length,
                (indexFirst) {
                  // if (attributes[index]["id"] == 1) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
                        child: Text(attributes[indexFirst]["id"] == "1"
                            ? "FILTER BY SIZE"
                            : "FILTER BY FABRIC"),
                      ),
                      ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: attributes[indexFirst]["id"] == "1"
                              ? selectedSizes.contains(
                                  attributes[indexFirst]["values"][index])
                              : selectedFabric.contains(
                                  attributes[indexFirst]["values"][index]),
                          onChanged: (value) {
                            if (attributes[indexFirst]["id"] == "1") {
                              if (value) {
                                selectedSizes.add(
                                    attributes[indexFirst]["values"][index]);
                              } else {
                                selectedSizes.remove(
                                    attributes[indexFirst]["values"][index]);
                              }
                            } else {
                              if (value) {
                                selectedFabric.add(
                                    attributes[indexFirst]["values"][index]);
                              } else {
                                selectedFabric.remove(
                                    attributes[indexFirst]["values"][index]);
                              }
                            }
                            setState(() {});
                          },
                          title: Text(attributes[indexFirst]["values"][index]),
                        ),
                        itemCount: attributes[indexFirst]["values"].length,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildChip(
      Map label, Color color, String categoryType, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 2.0, left: 2.0),
      child: FilterChip(
        padding: EdgeInsets.all(4.0),
        label: Text(
          label["name"],
          style: TextStyle(
              color:
                  selectedCategory == label["name"] ? Colors.white : textColor),
        ),
        backgroundColor: selectedCategory == label["name"]
            ? Theme.of(context).primaryColor
            : Colors.transparent,
        shape: StadiumBorder(
          side: selectedCategory == label["name"]
              ? BorderSide.none
              : BorderSide(color: color),
        ),
        onSelected: (bool value) {
          setState(() {
            selectedCategory = label["name"];
          });
          if (categoryType == "sub") {
            getSubCategory(label["id"].toString());
          } else if (categoryType == "subsub") {
            getSubSubCategory(label["id"].toString());
          } else {
            fetchProducts("subsubcategory", label["slug"]);
          }
        },
      ),
    );
  }

  fetchProducts(String type, String slug) {
    print(api_url + "search?$type=$slug");
    commeonMethod5(
      api_url + "search?$type=$slug",
      Provider.of<UserData>(context, listen: false).userData['api_token'],
    ).then((onResponse) {
      print(onResponse.body);
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        attributes = data["filter_data"]["attributes"];
        products = data["filter_data"]["products"]["data"];
        allColors = data["filter_data"]["all_colors"];
        lastFetchUrl = api_url + "search?$type=$slug";
        print(data);
        setState(() {});
      } else {
        presentToast(data['message'], context, 0);
      }
    });
  }

  void getSubCategory(String categoryId) {
    setState(() {
      getProgressDialog(context, "Fetching sub category").show();
    });
    print(api_url + "sub-categories?category_id=" + categoryId);
    commeonMethod2(api_url + "sub-categories?category_id=" + categoryId,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
      Map data = json.decode(onResponse.body);
      // print(data);
      if (data['code'] == 200) {
        setState(() {
          subCategoryList = data['sub_categories'];
          fetchProducts("subcategory", data["slug"]);
          print(subCategoryList);
        });
      } else {
        presentToast(data['message'], context, 0);
      }
    }).catchError((onerr) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
    });
  }

  Future<void> getSubSubCategory(String categoryId) async {
    setState(() {
      getProgressDialog(context, "Fetching sub sub category").show();
    });
    print(api_url + "sub-sub-categories?sub_category_id=" + categoryId);
    commeonMethod2(api_url + "sub-sub-categories?sub_category_id=" + categoryId,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          subSubCategoryList = data['sub_sub_categories'];
          // brandList = data['brands'];
        });
        fetchProducts("subsubcategory", data["slug"]);
      } else {
        presentToast(data['message'], context, 0);
      }
    }).catchError((onerr) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
    });
  }
}
