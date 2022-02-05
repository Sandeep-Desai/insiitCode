import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insiit/features/map/info_window.dart';
import 'package:insiit/features/map/search.dart';
import 'package:insiit/global/data/constants.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _locationTracker = Location();
  StreamSubscription? _locationSubscription;

  Circle circle =
      const Circle(circleId: CircleId(""), radius: 100, fillColor: Colors.blue);

  static LatLng center = const LatLng(23.21218113763076, 72.68640994061637);

  final Set<Marker> _markers = {};

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
    setState(() {
      _markers.add(Marker(
          markerId: const MarkerId("User"),
          position: latlng,
          rotation: newLocalData.heading ?? 0,
          draggable: false,
          zIndex: 10,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: getIcon('user')));

      circle = Circle(
          circleId: const CircleId("Accuracy"),
          radius: newLocalData.accuracy?.toDouble() ?? 0,
          zIndex: 1,
          strokeColor: Colors.blue,
          strokeWidth: 1,
          center: latlng,
          fillColor: Colors.blue);
    });
  }

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location);

      _locationSubscription?.cancel();

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
      zoom: 16,
      tilt: 30.0,
      bearing: location.heading ?? 0,
    ));
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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
          const ImageConfiguration(devicePixelRatio: 2.5),
          icons[i] ?? "assets/map/icons/user.png");
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

  _markerSet() async {
    // TODO
    dataContainer.map.sheet.getData('map!A:J').listen((data) {
      var mapData = data;
      mapInfoWindowList = [];
      locationList = [];
      keywordList = [];
      mapData.removeAt(0);
      mapData.forEach((location) {
        locationList.add(location[1]);
        keywordList.add(location[1] + location[8]);
        mapInfoWindowList.add(MapInfoWindow(
          locationName: location[1],
          location:
              LatLng(double.parse(location[3]), double.parse(location[4])),
          imagePath: location[9],
          timing: location[5],
          descriptionOne: location[6],
          descriptionTwo: location[7],
        ));
        _markers.add(Marker(
          markerId: MarkerId(location[1]),
          position:
              LatLng(double.parse(location[3]), double.parse(location[4])),
          infoWindow: InfoWindow(
            title: location[1],
            snippet: location[5],
          ),
          onTap: () {
            setState(() {
              currentWindow = mapInfoWindowList[int.parse(location[0])];
              mapInfoWindowPosition = -170;
            });
          },
          icon: getIcon(location[2]),
        ));
      });
      setState(() {});
    });
    return _markers;
  }

  void moveCamera(CameraPosition position) async {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.hybrid,
            padding: const EdgeInsets.only(top: 75.0),
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            myLocationEnabled: false,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: _onMapCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 16,
              tilt: 30.0,
              bearing: 180.0,
            ),
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                northeast: const LatLng(23.221005, 72.701542),
                southwest: const LatLng(23.201905, 72.678445),
              ),
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
            markers: _markers,
            circles: {circle},
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
              child: FloatingActionButton(
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
                          zoom: 16,
                          tilt: 30.0,
                          bearing: 180.0,
                        ));
                      }));
                },
                heroTag: "btn1",
                // backgroundColor: primaryColor,
                tooltip: 'Search',
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: mapInfoWindowPosition,
            left: 0,
            right: 0,
            duration: const Duration(milliseconds: 200),
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
                  margin: const EdgeInsets.all(15),
                  height: 350,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: currentWindow.imagePath,
                            fadeInDuration: const Duration(milliseconds: 300),
                            height: 100,
                            width: 1040,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(top: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      currentWindow.locationName,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 25,
                                      ),
                                    ),
                                    Text(
                                      currentWindow.timing,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(22),
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
                                  icon: const Icon(Icons.directions),
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
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          currentWindow.descriptionOne,
                                          style: const TextStyle(
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
                            const Divider(
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
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          currentWindow.descriptionTwo,
                                          style: const TextStyle(
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
                            const SizedBox(height: 20),
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
                    child: const Icon(Icons.my_location, color: Colors.black45),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      moveCamera(CameraPosition(
                        target: center,
                        zoom: 16.2,
                        tilt: 30.0,
                        bearing: 180.0,
                      ));
                    },
                    heroTag: "btn4",
                    backgroundColor: Colors.white,
                    tooltip: 'IITGN',
                    child: const Icon(Icons.home, color: Colors.black45),
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
  bool get wantKeepAlive => true;
}
