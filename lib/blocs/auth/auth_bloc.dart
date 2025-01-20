// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithEmailAndPassword(
          event.email,
          event.password,
        );
        if (user != null) {
          emit(Authenticated(email: user.email!));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }

    });
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.getCurrentUser(); // Assume this method checks if a user is logged in.
        if (user != null) {
          emit(Authenticated(email: user.email!));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });
  }
}
