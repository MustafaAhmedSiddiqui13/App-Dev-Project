import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<GeoPoint?> getCurrentLocation() async {
  PermissionStatus status = await Permission.location.request();

  if (status.isGranted) {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return GeoPoint(position.latitude, position.longitude);
  } else {
    return null;
  }
}

Future<void> updateLocation() async {
  final user = FirebaseAuth.instance.currentUser;

  // Get current location
  final currentPosition = await getCurrentLocation();

  // Update user's location in Firestore
  await FirebaseFirestore.instance.collection('riders').doc(user!.uid).update({
    'location': GeoPoint(
      currentPosition?.latitude ?? 0,
      currentPosition?.longitude ?? 0,
    ),
  });
}

Future<void> updatePostStatus({
  required String? riderUid,
  required String postId,
  required int postStatus,
}) async {
  await FirebaseFirestore.instance.collection('posts').doc(postId).update({
    'accepted': postStatus,
    'riderUid': riderUid,
  });
}

Future<void> updateRiderStatus({
  required String? riderUid,
  required String status,
}) async {
  if (riderUid != null) {
    await FirebaseFirestore.instance.collection('riders').doc(riderUid).update({
      'status': status,
    });
  } else {
    print("Error: riderUid is null");
  }
}
