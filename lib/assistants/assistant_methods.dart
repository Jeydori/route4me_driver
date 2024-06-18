import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:route4me_driver/assistants/request_assistant.dart';
import 'package:route4me_driver/global/directions.dart';
import 'package:route4me_driver/global/global.dart';
import 'package:route4me_driver/global/map_key.dart';
import 'package:route4me_driver/info%20handler/app_info.dart';
import 'package:route4me_driver/models/direction_infos.dart';
import 'package:route4me_driver/models/user_model.dart';

class assistantMethods {
  static Future<UserModel> readCurrentOnlineUserInfo() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .ref()
            .child('Drivers')
            .child(currentUser.uid);

        DatabaseEvent event = await userRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);
          UserModel userModel = UserModel(
            firstName: data['First Name'] ?? '',
            lastName: data['Last Name'] ?? '',
            age: data['Age'] ?? 0,
            email: data['Email'] ?? '',
            uid: currentUser.uid,
          );

          return userModel;
        } else {
          throw Exception('User document does not exist');
        }
      } else {
        throw Exception('Current user is null');
      }
    } catch (error) {
      rethrow; // Propagate the error for handling by the caller
    }
  }

  static Future<void> updateUserInfo(UserModel updatedUserModel) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .ref()
            .child('Drivers')
            .child(currentUser.uid);

        await userRef.update({
          'First Name': updatedUserModel.firstName,
          'Last Name': updatedUserModel.lastName,
          'Age': updatedUserModel.age,
          'Email': updatedUserModel.email,
        });
      } else {
        throw Exception('Current user is null');
      }
    } catch (error) {
      rethrow; // Propagate the error for handling by the caller
    }
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiURL);

    if (requestResponse != "Error Occurred. Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<appInfo>(context, listen: false)
          .updatePickUpAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
}
