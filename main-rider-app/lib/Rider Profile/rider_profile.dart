import 'package:flutter/material.dart';
import '../bloc/rider_profile_bloc.dart';

class RiderProfile extends StatefulWidget {
  const RiderProfile({Key? key}) : super(key: key);

  @override
  RiderProfileState createState() => RiderProfileState();
}

class RiderProfileState extends State<RiderProfile> {
  late RiderProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RiderProfileBloc();
    _bloc.fetchRiderData();
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
        title: const Text('Rider Profile'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _bloc.riderDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final riderData = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Name'),
                        subtitle: Text(riderData['name'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showTextEditDialog(
                              context,
                              'name',
                              riderData['name'].toString(),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Email'),
                        subtitle: Text(riderData['email'] ?? ''),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Phone Number'),
                        subtitle: Text(riderData['phone_number'].toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showIntEditDialog(
                              context,
                              'phone_number',
                              riderData['phone_number'].toString(),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Vehicle Number"),
                        subtitle: Text(riderData['vehicle_number'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showTextEditDialog(
                              context,
                              'vehicle_number',
                              riderData['vehicle_number'].toString(),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Vehicle Type"),
                        subtitle: Text(riderData['vehicle_type'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showDropDownEditDialog(
                              context,
                              'vehicle_type',
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Age"),
                        subtitle: Text(riderData['age'].toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showIntEditDialog(
                              context,
                              'age',
                              riderData['age'].toString(),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Rating"),
                        subtitle: Text(riderData['rating'].toString()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Placeholder or loading state while data is being fetched
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          );
        },
      ),
    );
  }

  void _showTextEditDialog(
      BuildContext context, String fieldName, String initialValue) {
    TextEditingController textEditingController =
        TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: 'Enter $fieldName',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                var updatedValue = textEditingController.text;
                _bloc.updateStringValue(fieldName, updatedValue);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showIntEditDialog(
      BuildContext context, String fieldName, String initialValue) {
    TextEditingController textEditingController =
        TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: 'Enter $fieldName',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                var updatedValue = int.parse(textEditingController.text);
                _bloc.updateIntValue(fieldName, updatedValue);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDropDownEditDialog(BuildContext context, String fieldName) {
    String? _vehicleType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: DropdownButtonFormField<String>(
            hint: const Text('Vehicle Type'),
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              prefixIcon: Icon(Icons.fire_truck),
              labelText: "Vehicle type",
              hintText: 'Choose your vehicle',
              border: OutlineInputBorder(),
            ),
            value: _vehicleType,
            onChanged: (String? value) {
              _vehicleType = value;
            },
            items: const [
              DropdownMenuItem(
                value: 'Bike',
                child: Text('Bike'),
              ),
              DropdownMenuItem(
                value: 'Car',
                child: Text('Car'),
              ),
              DropdownMenuItem(
                value: 'Suzuki',
                child: Text('Suzuki'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                var updatedValue = _vehicleType;
                _bloc.updateDropdownValue(fieldName, updatedValue!);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
