import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import '../Schema/post_json.dart';
import 'general_methods.dart';

class TrackFoodBloc {
  final _currentLocationSubject = BehaviorSubject<GeoPoint?>();
  final _riderStatusSubject = BehaviorSubject<String>();

  Stream<GeoPoint?> get currentLocationStream => _currentLocationSubject.stream;
  Stream<String> get riderStatusStream => _riderStatusSubject.stream;

  Future<void> getCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocationSubject
          .add(GeoPoint(position.latitude, position.longitude));
    } else {
      _currentLocationSubject.add(null);
    }
  }

  Future<void> updateRiderStatus(String status) async {
    final riderUid = FirebaseAuth.instance.currentUser?.uid;

    if (riderUid != null) {
      await FirebaseFirestore.instance
          .collection('riders')
          .doc(riderUid)
          .update({
        'status': status,
      });
    } else {
      print("Error: riderUid is null");
    }
  }

  void confirmPickup(PostJson post) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;
    updateRiderStatus('pickedup');
    _riderStatusSubject.add('pickedup');
  }

  void cancelOrder(BuildContext context, PostJson post) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("The Order is about to be Cancelled"),
          content: const Text("Are you sure you want to cancel it?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await updateRiderStatus('available');
                await updatePostStatus(
                  riderUid: riderId,
                  postId: post.pid,
                  postStatus: 1,
                );
                Navigator.of(context).pushNamed('/home/');
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void dispose() {
    _currentLocationSubject.close();
    _riderStatusSubject.close();
  }
}
