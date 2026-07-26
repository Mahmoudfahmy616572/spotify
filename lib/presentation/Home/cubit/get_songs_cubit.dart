import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecase/songs/get_charts_usecase.dart';
import 'package:spotify/presentation/Home/cubit/get_songs_state.dart';
import 'package:spotify/serviece_locator.dart';

class GetSongsCubit extends Cubit<GetSongsState> {
  GetSongsCubit() : super(GetSongsLoading());

  Future<void> fetchSongs() async {
    emit(GetSongsLoading());
    var returnedSongs = await getIt<GetChartsUsecase>().call(param: 'eg');
    returnedSongs.fold(
      (l) => emit(GetSongsFailure(l)),
      (data) => emit(GetSongsLoaded(songs: data)),
    );
  }
}
