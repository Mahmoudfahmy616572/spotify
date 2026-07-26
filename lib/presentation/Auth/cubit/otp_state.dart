import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpSending extends OtpState {}

class OtpSent extends OtpState {
  final String message;
  OtpSent(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerifying extends OtpState {}

class OtpVerified extends OtpState {
  final String message;
  OtpVerified(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpFailure extends OtpState {
  final String errorMessage;
  OtpFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
