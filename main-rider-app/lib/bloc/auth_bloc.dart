import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define the events
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

// Define the states
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure({required this.errorMessage});
}

// Define the bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure(errorMessage: "Authentication failed"));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }
}
