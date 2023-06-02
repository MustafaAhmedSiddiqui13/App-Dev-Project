import 'package:cloud_firestore/cloud_firestore.dart';
import '../Domain/org_respository.dart';
import 'JSON/org_json.dart';

class FirebaseOrgRepository implements OrgRepository {
  final db = FirebaseFirestore.instance;

  @override
  Future<List<OrgJson>> getOrgs() async {
    List<OrgJson> orgs = [];

    await db.collection("organizations").get().then((e) {
      orgs = e.docs.map((e) => OrgJson.fromJson(e.data())).toList();
      print("Length: " + orgs.length.toString());
    });

    return orgs;
  }
}
