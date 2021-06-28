import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/widgets/searchMapPlaceWidget.dart';
import 'addNewAddrress.dart';
import 'package:littardo/widgets/submitbutton.dart';

class AddLocation extends StatefulWidget {
  String isCash;
  String from;
  String productname;
  Map address;
  final double grandTotal;
  final double couponDiscount;
  String packageid;
  String type;
  String method;

  AddLocation(String isCash, Map address, String from, this.grandTotal,
      this.couponDiscount, this.productname,String packageid,
  String type,this.method) {
    this.isCash = isCash;
    this.from = from;
    this.address = address;
    this.productname = productname;
    this.packageid = packageid;
    this.type = type;
    this.method =  method;
  }

  _AddLocationState createState() => _AddLocationState(isCash, address, from);
}

class _AddLocationState extends State<AddLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );
  Set<Marker> markers = Set();
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor myIcon;

  String cityName = "";
  String locationTitle = "";
  String lattitude = "";
  String longitude = "";
  String fulladdress = "";
  String erbil = 'Erbil';
  String acccessToken = "";
  Address addrMap;

  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _address1controller = new TextEditingController();
  String isCash;
  Map address;
  String from;
  bool firstTime = true;
  bool showBottomSheet = false;

  _AddLocationState(String isCash, Map address, String from) {
    this.isCash = isCash;
    this.from = from;
    this.address = address;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getLocation();
      setIcons();
    });
    super.initState();
  }

  getLocation() async {
    getProgressDialog(context, "Fetching location...").show();
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    bool locationenabled = await geolocator.isLocationServiceEnabled();
    if (!locationenabled) {
      showInSnackBar(
          'Please allow permission to access location',
          SnackBarAction(
            label: 'OK',
            textColor: Colors.orange,
            onPressed: () {
//              SystemNavigator.pop();
            },
          ));
      getProgressDialog(context, "Fetching location...").hide(context);
    }
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      print(position);
      if (address != null && firstTime) {
        setState(() {
          firstTime = false;
        });
        getUpdatedLocation(
            double.parse(address['lat']), double.parse(address['lon']));
      } else {
        getUpdatedLocation(position.latitude, position.longitude);
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getUpdatedLocation(latitude, longitude) {
    if (markers.length > 0) {
      markers.remove(markers.firstWhere(
          (Marker marker) => marker.markerId == MarkerId("currentLocation")));
    }
    setState(() {
      markers.add(Marker(
          markerId: MarkerId("currentLocation"),
          icon: myIcon,
          draggable: true,
          position: LatLng(latitude, longitude),
          onDragEnd: ((value) {
            getLocationAddress(value.latitude, value.longitude);
          })));
    });
    new Timer(new Duration(milliseconds: 2000), () {
      _UpdateCurrentLocation(CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      ));

      getLocationAddress(latitude, longitude);
    });
  }

  Future<void> _UpdateCurrentLocation(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: _buildMap(context),
            )));
  }

  List<Widget> _buildMap(BuildContext context) {
    var list = new List<Widget>();
    var mapView = new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _currentPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onCameraMoveStarted: () {
           setState(() {
                    showBottomSheet=false;
                  });
        },
        markers: markers,
      ),
    );
    list.add(mapView);
    var addressView = Container(
      width: MediaQuery.of(context).size.width,
      color: showBottomSheet?Colors.white:Colors.transparent,
      margin: showBottomSheet?EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5):EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.7),
      child: showBottomSheet?ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(Icons.location_on),
                color: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                label: Text(locationTitle,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(fulladdress,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: TextField(
              controller: _namecontroller,
              enabled: false,
              style: TextStyle(fontSize: 13.0),
              decoration: new InputDecoration(
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: 'Lattitude',
                hintStyle: TextStyle(fontSize: 13),
                fillColor: Colors.white,
                //fillColor: Colors.green
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: TextField(
              controller: _address1controller,
              enabled: false,
              style: TextStyle(fontSize: 13.0),
              decoration: new InputDecoration(
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: 'Longitude',
                hintStyle: TextStyle(fontSize: 13),
                fillColor: Colors.white,
                //fillColor: Colors.green
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SubmitButton(
                title: 'CONFIRM',
                act: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddNewAddress(
                          isCash,
                          address,
                          from,
                          lattitude,
                          longitude,
                          addrMap,
                          widget.grandTotal,
                          widget.couponDiscount,
                          widget.productname,
                          widget.packageid,widget.type,widget.method)));
                },),
          ),
        ],
      ):Padding(
            padding: const EdgeInsets.all(16.0),
            child: SubmitButton(
                title: 'SET LOCATION',
                act: () {
                  setState(() {
                    showBottomSheet=!showBottomSheet;
                  });
                },),
          ),
    );
    list.add(addressView);
    var searchbar = Positioned(
        top: 40,
        left: MediaQuery.of(context).size.width * 0.05,
        // width: MediaQuery.of(context).size.width * 0.9,
        child: SearchMapPlaceWidget(
          apiKey: "AIzaSyDQ59Rutw8vk302ksp4w0rHfWyLT4KhxfA",
          location: _currentPosition.target,
          radius: 30000,
          onSelected: (place) async {
            final geolocation = await place.geolocation;
            if (markers.length > 0) {
              markers.remove(markers.firstWhere((Marker marker) =>
                  marker.markerId == MarkerId("currentLocation")));
            }
            markers.add(Marker(
              markerId: MarkerId("currentLocation"),
              icon: myIcon,
              position: geolocation.coordinates,
              draggable: true,
              onDragEnd: ((value) {
                getLocationAddress(value.latitude, value.longitude);
                _UpdateCurrentLocation(CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                  zoom: 14.4746,
                ));
              }),
              onTap: () => {},
            ));
            _UpdateCurrentLocation(CameraPosition(
              target: geolocation.coordinates,
              zoom: 14.4746,
            ));
            getLocationAddress(geolocation.coordinates.latitude,
                geolocation.coordinates.longitude);
          },
        ));
    list.add(searchbar);

    return list;
  }

  Widget _customicon(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          "assets/imgs/littardo_logo.png",
          height: 500,
          width: 500,
        ),
      ),
      decoration: new BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }

  _displaySnackBar(msg) {
    final snackBar = new SnackBar(
      content: Text(msg),
      backgroundColor: Colors.black,
      action: SnackBarAction(
        label: 'ok',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future setIcons() async {
    myIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/gps.png', 100));
  }

  Future getLocationAddress(latitude, long) async {
    final coordinates = new Coordinates(latitude, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      addrMap = addresses.first;
      lattitude = latitude.toString();
      longitude = long.toString();
      cityName = first.locality != null ? first.locality : "";
      locationTitle = first.subLocality != null ? first.subLocality : "";
      _namecontroller.text = lattitude;
      _address1controller.text = longitude;
      fulladdress = first.addressLine;
    });
    print(
        ' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    getProgressDialog(context, "Fetching location...").hide(context);
  }

  void showInSnackBar(String value, SnackBarAction snackBarAction) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(days: 1),
          content: new Text(value),
          action: snackBarAction,
        ))
        .closed
        .then((reason) {
      if (reason == SnackBarClosedReason.swipe) {
        showInSnackBar(value, snackBarAction);
      }
    });
  }
}
