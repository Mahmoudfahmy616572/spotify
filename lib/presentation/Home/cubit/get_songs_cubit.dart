import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/data/sources/songs/get_songs_supabase_servieces.dart';
import 'package:spotify/presentation/Home/cubit/get_songs_state.dart';
import 'package:spotify/serviece_locator.dart';

class GetSongsCubit extends Cubit<GetSongsState> {
  GetSongsCubit() : super(GetSongsLoading());

  Future<void> fetchSongs() async {
    emit(GetSongsLoading());
    var returnedSongs = await getIt<SongsSupabaseServieces>().getNewSongs();
    returnedSongs.fold(
      (l) => emit(GetSongsFailure(l)),
      (data) => emit(GetSongsLoaded(songs: data)),
    );
  }
}
