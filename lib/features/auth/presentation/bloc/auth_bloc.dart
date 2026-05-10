import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/utils/error_helper.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthStateInitial()) {
    
    on<AuthStarted>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthStateAuthenticated(user));
        } else {
          emit(const AuthStateUnauthenticated());
        }
      } catch (e) {
        emit(AuthStateError(e.toString()));
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        final user = await _authRepository.signIn(
          event.email,
          event.password,
        );
        emit(AuthStateAuthenticated(user));
      } catch (e) {
        emit(AuthStateError(ErrorHelper.getMessage(e)));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        final user = await _authRepository.signUp(
          event.email,
          event.password,
          event.name,
          event.phoneNumber,
          event.userType,
          confirmedSimSwap: event.confirmSecurityWarning,
        );
        emit(AuthStateAuthenticated(user));
      } on SimSwapException catch (e) {
        emit(AuthStateSecurityWarning(swapDate: e.swapDate));
      } catch (e) {
        emit(AuthStateError(ErrorHelper.getMessage(e)));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await _authRepository.signOut();
        emit(const AuthStateUnauthenticated());
      } catch (e) {
        emit(AuthStateError(ErrorHelper.getMessage(e)));
      }
    });

    on<PasswordResetRequested>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await _authRepository.resetPassword(event.email);
        emit(const AuthStatePasswordResetSent());
      } catch (e) {
        emit(AuthStateError(e.toString()));
      }
    });

    on<UserUpdated>((event, emit) async {
      emit(AuthStateAuthenticated(event.user));
    });
  }
}
