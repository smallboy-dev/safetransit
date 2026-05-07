part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final UserType userType;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.userType,
  });

  @override
  List<Object> get props => [email, password, name, phoneNumber, userType];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class UserUpdated extends AuthEvent {
  final User user;

  const UserUpdated(this.user);

  @override
  List<Object> get props => [user];
}
