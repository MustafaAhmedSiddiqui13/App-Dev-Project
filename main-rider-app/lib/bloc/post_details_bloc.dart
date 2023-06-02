// Define the events
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rider_app/bloc/general_methods.dart';

abstract class PostDetailsEvent {}

class FetchCurrentLocation extends PostDetailsEvent {}

class AcceptAndPickFood extends PostDetailsEvent {
  final String postId;
  final int postStatus;

  AcceptAndPickFood({
    required this.postId,
    required this.postStatus,
  });
}

// Define the state
abstract class PostDetailsState {}

class PostDetailsInitial extends PostDetailsState {}

class PostDetailsLoading extends PostDetailsState {}

class PostDetailsLoaded extends PostDetailsState {
  final GeoPoint currentUserLocation;

  PostDetailsLoaded(this.currentUserLocation);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostDetailsLoaded &&
        other.currentUserLocation == currentUserLocation;
  }

  @override
  int get hashCode => currentUserLocation.hashCode;
}

class PostDetailsError extends PostDetailsState {
  final String error;

  PostDetailsError(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostDetailsError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

// Define the BLoC class
class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final FirebaseFirestore firestore;

  PostDetailsBloc(this.firestore) : super(PostDetailsInitial()) {
    on<FetchCurrentLocation>(_fetchCurrentLocation);
    on<AcceptAndPickFood>(_acceptAndPickFood);
  }

  Future<void> _fetchCurrentLocation(
      FetchCurrentLocation event, Emitter<PostDetailsState> emit) async {
    emit(PostDetailsLoading());

    try {
      final PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        emit(
            PostDetailsLoaded(GeoPoint(position.latitude, position.longitude)));
      } else {
        emit(PostDetailsError('Location permission denied.'));
      }
    } catch (error) {
      emit(PostDetailsError(error.toString()));
    }
  }

  Future<void> _acceptAndPickFood(
      AcceptAndPickFood event, Emitter<PostDetailsState> emit) async {
    emit(PostDetailsLoading());

    try {
      final riderId = FirebaseAuth.instance.currentUser?.uid;
      final riderDoc = firestore.collection('riders').doc(riderId);
      final riderSnapshot = await riderDoc.get();
      String status = "";

      if (riderSnapshot.exists) {
        final data = riderSnapshot.data();
        if (data != null) {
          status = data['status'];
        }
      }

      await updateLocation();

      if (status == 'available' || status == 'completed') {
        final postId = event.postId;
        final postStatus = event.postStatus;

        await updatePostStatus(
          riderUid: riderId,
          postId: postId,
          postStatus: postStatus,
        );

        await updateRiderStatus(
          riderUid: riderId,
          status: 'accepted',
        );

        emit(PostDetailsLoaded(const GeoPoint(0, 0)));
      } else {
        emit(PostDetailsError("You have an order in progress already"));
      }
    } catch (error) {
      emit(PostDetailsError(error.toString()));
    }
  }
}
