part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final User user;

  const AuthStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

class AuthStateSecurityWarning extends AuthState {
  final String? swapDate;

  const AuthStateSecurityWarning({this.swapDate});

  @override
  List<Object?> get props => [swapDate];
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
