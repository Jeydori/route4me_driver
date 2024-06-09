import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route4me_driver/assistants/assistant_methods.dart';
import 'package:route4me_driver/global/global.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition Manila = CameraPosition(
    target: LatLng(14.599512, 120.984222),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? locationPermission;
  StreamSubscription<Position>? streamSubscriptionPosition;

  String statusText = 'Now Offline';
  Color buttonColor = Colors.orange.shade600;
  bool isDriverActive = false;
  bool isVehicleFull = false;

  checkIfLocationPermissionAllowed() async {
    locationPermission = await Geolocator.requestPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await assistantMethods
        .searchAddressForGeographicCoordinates(driverCurrentPosition!, context);
    print('This is our address = $humanReadableAddress');
  }

  readCurrentDriverInformation() async {
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance
        .ref()
        .child('Drivers')
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.firstName = (snap.snapshot.value as Map)['First Name'];
        onlineDriverData.lastName = (snap.snapshot.value as Map)['Last Name'];
        onlineDriverData.age = (snap.snapshot.value as Map)['Age'];
        onlineDriverData.email = (snap.snapshot.value as Map)['Email'];
        onlineDriverData.carPlate = (snap.snapshot.value as Map)["carPlate"];
        onlineDriverData.carType = (snap.snapshot.value as Map)["carType"];

        driverVehicleType = (snap.snapshot.value as Map)['type'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  void dispose() {
    streamSubscriptionPosition
        ?.cancel(); // Cancel the subscription when the state is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 40),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            initialCameraPosition: Manila,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              if (isDriverActive) {
                locateDriverPosition();
              }
            },
          ),

          // Overlay for online/offline UI
          statusText != 'Now Online'
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : Container(),

          Positioned(
            top: statusText != 'Now Online'
                ? MediaQuery.of(context).size.height * 0.45
                : 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: toggleDriverStatus,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating action buttons for vehicle status
          if (isDriverActive) ...[
            Positioned(
              bottom: 110,
              right: 10,
              child: FloatingActionButton(
                onPressed: () => setVehicleStatus(true),
                backgroundColor: Colors.red,
                child: Icon(Icons.bus_alert_outlined),
                tooltip: 'Set Vehicle as Full',
              ),
            ),
            Positioned(
              bottom: 50,
              right: 10,
              child: FloatingActionButton(
                onPressed: () => setVehicleStatus(false),
                backgroundColor: Colors.green,
                child: Icon(Icons.directions_bus_filled_outlined),
                tooltip: 'Set Vehicle as Available',
              ),
            ),
          ],
        ],
      ),
    );
  }

  void toggleDriverStatus() {
    if (!isDriverActive) {
      driverIsOnlineNow();
      updateDriversLocationAtRealtime();
      setState(() {
        statusText = 'Now Online';
        isDriverActive = true;
        buttonColor = Colors.transparent;
      });
    } else {
      driverIsOfflineNow();
      setState(() {
        statusText = 'Now Offline';
        isDriverActive = false;
        buttonColor = Colors.orange.shade600;
      });
    }
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    driverCurrentPosition = pos;

    Geofire.initialize('activeDrivers');
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('Drivers')
        .child(currentUser!.uid)
        .child('newRideStatus');

    ref.set('idle');
    ref.onValue.listen((event) {});
  }

  updateDriversLocationAtRealtime() {
    streamSubscriptionPosition
        ?.cancel(); // First, cancel any existing subscription.
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive && !isVehicleFull) {
        // Check if the driver is active and the vehicle is not full.
        Geofire.setLocation(
            currentUser!.uid, position.latitude, position.longitude);
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
      }
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child('Drivers')
        .child(currentUser!.uid)
        .child('newRideStatus');

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }

  void setVehicleStatus(bool full) {
    setState(() {
      isVehicleFull = full;
    });
    if (isVehicleFull) {
      Geofire.removeLocation(currentUser!.uid);
      streamSubscriptionPosition
          ?.cancel(); // Cancel the location stream when the vehicle is full.
    } else {
      updateDriversLocationAtRealtime();
    }
  }
}
