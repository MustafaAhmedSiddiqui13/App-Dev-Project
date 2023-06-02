import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Schema/org_json.dart';
import '../Schema/post_json.dart';
import '../Schema/user_json.dart';
import '../Startup Screens/timer.dart';
import 'general_methods.dart';

class NgoTrackFoodBloc {
  final StreamController<OrgJson?> _orgLocationController =
      StreamController<OrgJson?>.broadcast();

  Stream<OrgJson?> get orgLocationStream => _orgLocationController.stream;

  void dispose() {
    _orgLocationController.close();
  }

  void fetchOrgLocation(String nid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(nid).get();
      UserJson user = UserJson.fromJson(userDoc.data() as Map<String, dynamic>);

      QuerySnapshot orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: user.organisation)
          .get();

      if (orgQuery.docs.isNotEmpty) {
        DocumentSnapshot orgDoc = orgQuery.docs.first;
        final orgLocation =
            OrgJson.fromJson(orgDoc.data() as Map<String, dynamic>);
        _orgLocationController.add(orgLocation);
      } else {
        _orgLocationController.add(null);
      }
    } catch (e) {
      print("Error: $e");
      _orgLocationController.addError(e);
    }
  }

  void confirmOrderDelivered(
      BuildContext context, String riderId, PostJson post) {
    updatePostStatus(
      riderUid: riderId,
      postId: post.pid,
      postStatus: 2,
    );
    TimerClass().stopLocationUpdates();

    updateRiderStatus(
      riderUid: riderId,
      status: 'completed',
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home/',
      (route) => false,
      arguments: post,
    );
  }

  void openGoogleMaps(
      double lat1, double lon1, double lat2, double lon2) async {
    String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$lat1,$lon1&destination=$lat2,$lon2&travelmode=driving';
    String geoUrl = 'geo:$lat1,$lon1?q=$lat2,$lon2';

    if (await canLaunchUrl(Uri.parse(geoUrl))) {
      await launchUrl(Uri.parse(geoUrl));
    } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not launch Google Maps';
    }
  }
}
