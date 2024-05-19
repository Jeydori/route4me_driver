import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? locationPermission;

  String statusText = 'Now Offline';
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

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

  Future<void> readCurrentDriverInformation() async {
    var currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child("Drivers")
          .child(currentUser.uid);
      DatabaseEvent event = await driverRef.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> driverData =
            event.snapshot.value as Map<dynamic, dynamic>;

        onlineDriverData.firstName = driverData["First Name"];
        onlineDriverData.lastName = driverData["Last Name"];
        onlineDriverData.age = driverData["Age"];
        onlineDriverData.email = driverData["Email"];
        onlineDriverData.carPlate = driverData['car_details']["carPlate"];
        onlineDriverData.carType = driverData['car_details']["carType"];

        driverVehicleType = driverData["car_details"]["type"];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);

            newGoogleMapController = controller;

            setState(() {});
            locateDriverPosition();
          },
        )
      ],
    );
  }
}
