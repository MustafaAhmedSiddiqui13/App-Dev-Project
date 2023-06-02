import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Schema/post_json.dart';

class InProgressBloc extends Cubit<List<PostJson>> {
  final riderId = FirebaseAuth.instance.currentUser?.uid;

  InProgressBloc() : super([]);

  Future<void> fetchAcceptedPosts() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('accepted', isEqualTo: 3)
          .where('riderUid', isEqualTo: riderId)
          .get();

      final posts = querySnapshot.docs
          .map((doc) =>
              PostJson.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      emit(posts);
    } catch (error) {
      // Handle the error
      emit([]);
    }
  }

  Future<String> fetchRiderStatus() async {
    try {
      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('riders')
          .doc(riderId)
          .get();

      return riderDoc['status'];
    } catch (error) {
      // Handle the error
      return '';
    }
  }
}
