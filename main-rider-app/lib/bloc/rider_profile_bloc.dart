import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class RiderProfileBloc {
  final user = FirebaseAuth.instance.currentUser;

  final _riderDataSubject = BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get riderDataStream => _riderDataSubject.stream;

  void fetchRiderData() {
    FirebaseFirestore.instance
        .collection('riders')
        .doc(user!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final riderData = snapshot.data() as Map<String, dynamic>;
        _riderDataSubject.add(riderData);
      }
    });
  }

  void updateStringValue(String fieldName, String updatedValue) {
    FirebaseFirestore.instance
        .collection('riders')
        .doc(user!.uid)
        .update({fieldName: updatedValue});
  }

  void updateIntValue(String fieldName, int updatedValue) {
    FirebaseFirestore.instance
        .collection('riders')
        .doc(user!.uid)
        .update({fieldName: updatedValue});
  }

  void updateDropdownValue(String fieldName, String updatedValue) {
    FirebaseFirestore.instance
        .collection('riders')
        .doc(user!.uid)
        .update({fieldName: updatedValue});
  }

  void dispose() {
    _riderDataSubject.close();
  }
}
