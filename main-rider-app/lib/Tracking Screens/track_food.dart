import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Schema/post_json.dart';
import '../bloc/track_food_bloc.dart';

class TrackFood extends StatefulWidget {
  final PostJson post;
  const TrackFood({Key? key, required this.post}) : super(key: key);

  @override
  TrackFoodState createState() => TrackFoodState();
}

class TrackFoodState extends State<TrackFood> {
  late TrackFoodBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TrackFoodBloc();
    _bloc.getCurrentLocation();
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
            child: Column(
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
                const SizedBox(
                  height: 50,
                ),
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
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _bloc.currentLocationStream.listen((currentLocation) {
                          if (currentLocation != null) {
                            openGoogleMaps(
                              currentLocation.latitude,
                              currentLocation.longitude,
                              widget.post.lat,
                              widget.post.long,
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('Track Donor Location'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _bloc.confirmPickup(widget.post);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/ngotrackFood/',
                              (route) => false,
                              arguments: widget.post,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            textStyle: const TextStyle(fontSize: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                          ),
                          child: const Text('Confirm Pickup'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            _bloc.cancelOrder(context, widget.post);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(fontSize: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                          ),
                          child: const Text('Cancel Order'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
