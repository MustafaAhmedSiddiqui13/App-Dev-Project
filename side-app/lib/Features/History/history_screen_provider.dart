import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/JSON/post_json.dart';

class HistoryScreenProvider {
  final db = FirebaseFirestore.instance;

  Future<List<PostJson>> fetchPosts(String uid) async {
    try {
      final snapshot = await db
          .collection("posts")
          .where('accepted', isEqualTo: 2)
          .where('nid', isEqualTo: uid)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostJson.fromJson(doc.data(), doc.id))
          .toList();
      return posts;
    } catch (error) {
      // Handle fetch posts error
      print('Failed to fetch posts: $error');
      return [];
    }
  }
}
