import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insiit/global/data/constants.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MapInfoWindow {
  String imagePath;
  LatLng location;
  String locationName;
  String timing;
  String descriptionOne;
  String descriptionTwo;

  MapInfoWindow(
      {required this.imagePath,
      required this.location,
      required this.locationName,
      required this.timing,
      required this.descriptionOne,
      required this.descriptionTwo});
}

var keywordList = [];
var locationList = [];

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  Completer<GoogleMapController> _controller = Completer();

  Location _locationTracker = Location();

  late StreamSubscription _locationSubscription;

  late Marker marker;

  Circle circle =
      Circle(circleId: CircleId(""), radius: 100, fillColor: Colors.blue);

  static const LatLng _center = const LatLng(23.212838, 72.684738);

  Set<Marker> _markers = {};

  List<BitmapDescriptor> customIcons = List.generate(13, (index) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  });

  double mapInfoWindowPosition = -370;

  MapInfoWindow currentWindow = MapInfoWindow(
      imagePath: '',
      location: const LatLng(0, 0),
      locationName: '',
      timing: '',
      descriptionOne: '',
      descriptionTwo: '');

  var mapInfoWindowList = [];

  late String _mapStyle;

  @override
  void initState() {
    super.initState();
    setCustomIcons();
    rootBundle.loadString('assets/map/mapstyle.txt').then((string) {
      _mapStyle = string;
    });
  }

  void updateMarkerAndCircle(LocationData newLocalData) {
    LatLng latlng =
        LatLng(newLocalData.latitude ?? 0, newLocalData.longitude ?? 0);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("User"),
          position: latlng,
          rotation: newLocalData.heading ?? 0,
          draggable: false,
          zIndex: 10,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: getIcon('user'));
      _markers.add(marker);
      circle = Circle(
        circleId: CircleId("Accuracy"),
        radius: newLocalData.accuracy?.toDouble() ?? 0,
        zIndex: 1,
        // strokeColor: primaryColor.withAlpha(80),
        strokeWidth: 1,
        center: latlng,
        // fillColor: primaryColor.withAlpha(40)
      );
    });
  }

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged
          .listen((LocationData newLocalData) {
        updateMarkerAndCircle(newLocalData);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void _goToUserLocation() async {
    var location = await _locationTracker.getLocation();

    moveCamera(CameraPosition(
      target: LatLng(location.latitude ?? 0, location.longitude ?? 0),
      zoom: 17.2,
      tilt: 30.0,
      bearing: location.heading ?? 0,
    ));
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  void setCustomIcons() async {
    Map<int, String> icons = {
      0: 'assets/map/icons/general.png',
      1: 'assets/map/icons/academics.png',
      2: 'assets/map/icons/hostel.png',
      3: 'assets/map/icons/cafe.png',
      4: 'assets/map/icons/canteen.png',
      5: 'assets/map/icons/grocery.png',
      6: 'assets/map/icons/sports.png',
      7: 'assets/map/icons/landscape.png',
      8: 'assets/map/icons/medical.png',
      9: 'assets/map/icons/mess.png',
      10: 'assets/map/icons/parking.png',
      11: 'assets/map/icons/housing.png',
      12: 'assets/map/icons/user.png',
    };
    for (int i = 0; i < 13; i++) {
      customIcons[i] = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), icons[i] ?? "");
    }
  }

  BitmapDescriptor getIcon(String category) {
    Map<String, int> categoryMap = {
      'general': 0,
      'academic': 1,
      'hostel': 2,
      'cafe': 3,
      'canteen': 4,
      'grocery': 5,
      'sports': 6,
      'landscape': 7,
      'medical': 8,
      'mess': 9,
      'parking': 10,
      'housing': 11,
      'user': 12
    };
    return customIcons[categoryMap[category] ?? 0];
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setState(() {
      _markerSet();
    });
    getCurrentLocation();
    controller.setMapStyle(_mapStyle);
  }

  MapType _currentMapType = MapType.hybrid;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  _markerSet() async {
    // dataContainer.map.sheet.getData('map!A:J').listen((data) {
    //   var mapData = data;
    //   mapInfoWindowList = [];
    //   locationList = [];
    //   keywordList = [];
    //   mapData.removeAt(0);
    //   mapData.forEach((location) {
    //     locationList.add(location[1]);
    //     keywordList.add(location[1] + location[8]);
    //     mapInfoWindowList.add(MapInfoWindow(
    //       locationName: location[1],
    //       location:
    //           LatLng(double.parse(location[3]), double.parse(location[4])),
    //       imagePath: location[9],
    //       timing: location[5],
    //       descriptionOne: location[6],
    //       descriptionTwo: location[7],
    //     ));
    //     _markers.add(Marker(
    //       markerId: MarkerId(location[1]),
    //       position:
    //           LatLng(double.parse(location[3]), double.parse(location[4])),
    //       infoWindow: InfoWindow(
    //         title: location[1],
    //         snippet: location[5],
    //       ),
    //       onTap: () {
    //         setState(() {
    //           currentWindow = mapInfoWindowList[int.parse(location[0])];
    //           mapInfoWindowPosition = -170;
    //         });
    //       },
    //       icon: getIcon(location[2]),
    //     ));
    //   });
    //   setState(() {});
    // });
    return _markers;
  }

  moveCamera(CameraPosition position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void launchMap(double lat, double long) async {
    String url = "https://www.google.com/maps/search/?api=1&query=$lat,$long";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Maps';
    }
  }

  void navigateTo() {
    Navigator.pushNamed(context, '/tlcontacts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            padding: EdgeInsets.only(top: 75.0),
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            myLocationEnabled: false,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: _onMapCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.2,
              tilt: 30.0,
              bearing: 180.0,
            ),
            cameraTargetBounds: CameraTargetBounds(
              new LatLngBounds(
                northeast: LatLng(23.221005, 72.701542),
                southwest: LatLng(23.201905, 72.678445),
              ),
            ),
            minMaxZoomPreference: MinMaxZoomPreference(12, 20),
            markers: _markers,
            circles: Set.of((circle != null) ? [circle] : []),
            onTap: (LatLng location) {
              setState(() {
                mapInfoWindowPosition = -370;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: CustomSearch(),
                      ).then((value) => setState(() {
                            currentWindow =
                                mapInfoWindowList[int.parse(value ?? "0")];
                            mapInfoWindowPosition = -170;
                            moveCamera(CameraPosition(
                              target: currentWindow.location,
                              zoom: 17.2,
                              tilt: 30.0,
                              bearing: 180.0,
                            ));
                          }));
                    },
                    heroTag: "btn1",
                    // backgroundColor: primaryColor,
                    tooltip: 'Search',
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                  SizedBox(height: 16.0),
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    heroTag: "btn2",
                    backgroundColor: Colors.white,
                    tooltip: 'Layers',
                    child: Icon(Icons.layers, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: mapInfoWindowPosition,
            left: 0,
            right: 0,
            duration: Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    mapInfoWindowPosition = 0;
                  });
                },
                onVerticalDragDown: (details) {
                  setState(() {
                    mapInfoWindowPosition = 0;
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    mapInfoWindowPosition = -170;
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(15),
                  height: 350,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 15,
                            offset: Offset.zero,
                            color: Colors.black.withOpacity(0.4))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: currentWindow.imagePath,
                            fadeInDuration: Duration(milliseconds: 300),
                            height: 100,
                            width: 1040,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        margin: EdgeInsets.only(top: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      currentWindow.locationName,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 25,
                                      ),
                                    ),
                                    Text(
                                      currentWindow.timing,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(22),
                              child: CircleAvatar(
                                radius: 33,
                                // backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    launchMap(currentWindow.location.latitude,
                                        currentWindow.location.longitude);
                                  },
                                  tooltip: 'Directions',
                                  icon: Icon(Icons.directions),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 150,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          currentWindow.descriptionOne,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 40.0,
                              thickness: 0.9,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          currentWindow.descriptionTwo,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 75.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _goToUserLocation,
                    heroTag: "btn3",
                    backgroundColor: Colors.white,
                    tooltip: 'Your location',
                    child: Icon(Icons.my_location, color: Colors.black45),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      moveCamera(CameraPosition(
                        target: _center,
                        zoom: 17.2,
                        tilt: 30.0,
                        bearing: 180.0,
                      ));
                    },
                    heroTag: "btn4",
                    backgroundColor: Colors.white,
                    tooltip: 'IITGN',
                    child: Icon(Icons.home, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CustomSearch extends SearchDelegate<String> {
  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   assert(context != null);
  //   final ThemeData theme = Theme.of(context);
  //   assert(theme != null);
  //   return theme.copyWith(
  //     inputDecorationTheme: InputDecorationTheme(
  //           hintStyle: TextStyle(color: theme.primaryTextTheme.headline6.color.withOpacity(0.6))),
  //       primaryColor: theme.primaryColor,
  //       primaryIconTheme: theme.primaryIconTheme,
  //       primaryColorBrightness: theme.primaryColorBrightness,
  //       primaryTextTheme: theme.primaryTextTheme,
  //       textTheme: theme.textTheme.copyWith(
  //           headline6: theme.textTheme.headline6
  //               .copyWith(color: theme.primaryTextTheme.headline6.color))
  //   );
  // }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, "null");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //DONT REMOVE
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          height: 425,
          decoration: BoxDecoration(
            color: Colors.white10,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/map_search.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Text(
                    "This location search is powered by a comprehensive list of keywords. For example, if you search 'food', the dining hall and canteens will come up as suggestions.",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final suggestions = locationList
          .where((p) => keywordList[locationList.indexOf(p)]
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            close(context, locationList.indexOf(suggestions[index]).toString());
          },
          leading: Icon(Icons.location_city),
          title: Text(suggestions[index]),
        ),
        itemCount: suggestions.length,
      );
    }
  }
}
