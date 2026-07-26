import 'package:bloc/bloc.dart';
import 'package:spotify/domain/usecase/songs/search_songs_usecase.dart';
import 'package:spotify/serviece_locator.dart';

import 'search_songs_state.dart';

class SearchSongsCubit extends Cubit<SearchSongsState> {
  SearchSongsCubit() : super(SearchSongsInitial());

  void searchSongs(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchSongsInitial());
      return;
    }
    emit(SearchSongsLoading());

    final result = await getIt<SearchSongsUsecase>().call(param: query);
    result.fold(
      (l) => emit(SearchSongsError(l)),
      (songs) => emit(SearchSongsLoaded(songs)),
    );
  }
}
