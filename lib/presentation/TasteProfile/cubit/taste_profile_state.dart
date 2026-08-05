part of 'taste_profile_cubit.dart';

abstract class TasteProfileState extends Equatable {
  const TasteProfileState();

  @override
  List<Object?> get props => [];
}

class TasteProfileInitial extends TasteProfileState {}

class TasteProfileAnalyzing extends TasteProfileState {}

class TasteProfileLoaded extends TasteProfileState {
  final TasteProfile profile;
  const TasteProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TasteProfileError extends TasteProfileState {
  final String message;
  const TasteProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
