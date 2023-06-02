import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Schema/org_json.dart';
import '../Schema/post_json.dart';
import '../bloc/ngo_track_food_bloc.dart';

class NgoTrackFood extends StatefulWidget {
  final PostJson post;
  const NgoTrackFood({Key? key, required this.post}) : super(key: key);

  @override
  State<NgoTrackFood> createState() => _NgoTrackFoodState();
}

class _NgoTrackFoodState extends State<NgoTrackFood> {
  final NgoTrackFoodBloc _bloc = NgoTrackFoodBloc();

  @override
  void initState() {
    super.initState();
    _bloc.fetchOrgLocation(widget.post.nid);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Food'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<OrgJson?>(
              stream: _bloc.orgLocationStream,
              builder: (context, snapshot) {
                final orgLocation = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 20.0),
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Dashboard'),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Card(
                      child: ListTile(
                        title: const Text('Description of Food'),
                        subtitle: Text(widget.post.description),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Quantity'),
                        subtitle: Text(widget.post.quantity),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("NGO Representative's Name"),
                        subtitle: Text(widget.post.nname),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("NGO's Contact Number"),
                        subtitle: Text(widget.post.nnumber),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Donor's Name"),
                        subtitle: Text(widget.post.name),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _bloc.openGoogleMaps(
                              widget.post.lat,
                              widget.post.long,
                              orgLocation?.lat ?? 0,
                              orgLocation?.long ?? 0,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(fontSize: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                          ),
                          child: const Text('Track NGO Location'),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final riderId =
                                  FirebaseAuth.instance.currentUser?.uid;

                              _bloc.confirmOrderDelivered(
                                  context, riderId!, widget.post);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              textStyle: const TextStyle(fontSize: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                            ),
                            child: const Text('Confirm Order as Delivered'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
