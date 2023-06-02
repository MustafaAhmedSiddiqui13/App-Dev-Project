import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Schema/post_json.dart';
import '../Startup Screens/timer.dart';
import '../bloc/post_details_bloc.dart';

class PostDetailsScreen extends StatefulWidget {
  final PostJson post;

  const PostDetailsScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  PostDetailsScreenState createState() => PostDetailsScreenState();
}

class PostDetailsScreenState extends State<PostDetailsScreen> {
  late GoogleMapController _controller;
  late final TimerClass _timer = TimerClass();
  late PostDetailsBloc _postDetailsBloc;

  @override
  void initState() {
    super.initState();
    _postDetailsBloc = PostDetailsBloc(FirebaseFirestore.instance);
    _postDetailsBloc.add(FetchCurrentLocation());
  }

  @override
  void dispose() {
    _postDetailsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (context) => _postDetailsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.post.title),
          backgroundColor: Colors.teal,
        ),
        body: BlocBuilder<PostDetailsBloc, PostDetailsState>(
          builder: (context, state) {
            if (state is PostDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostDetailsError) {
              return Center(
                child: Text(state.error),
              );
            } else if (state is PostDetailsLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          title: const Text('Name of Donor'),
                          subtitle: Text(widget.post.name),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text("Donor's Contact Number"),
                          subtitle: Text(widget.post.number),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text("Name of NGO's Representative"),
                          subtitle: Text(widget.post.nname),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title:
                              const Text("NGO Representative's Contact Number"),
                          subtitle: Text(widget.post.nnumber),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                (state.currentUserLocation.latitude +
                                        widget.post.lat) /
                                    2,
                                (state.currentUserLocation.longitude +
                                        widget.post.long) /
                                    2,
                              ),
                              zoom: 13,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller = controller;
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('post_location'),
                                position:
                                    LatLng(widget.post.lat, widget.post.long),
                                infoWindow:
                                    const InfoWindow(title: "Food's Location"),
                              ),
                              Marker(
                                markerId: const MarkerId('user_location'),
                                position: LatLng(
                                  state.currentUserLocation.latitude,
                                  state.currentUserLocation.longitude,
                                ),
                                infoWindow:
                                    const InfoWindow(title: "My Location"),
                              ),
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _postDetailsBloc.add(AcceptAndPickFood(
                              postId: widget.post.pid,
                              postStatus: 3,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Accept and Pick Food'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is PostDetailsError) {
              return Center(
                child: Text(state.error),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
