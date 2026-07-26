import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecase/songs/get_charts_usecase.dart';
import 'package:spotify/presentation/Home/cubit/charts/charts_state.dart';
import 'package:spotify/serviece_locator.dart';

class ChartsCubit extends Cubit<ChartsState> {
  ChartsCubit() : super(ChartsLoading());

  Future<void> fetchCharts({String country = 'eg'}) async {
    emit(ChartsLoading());
    final result = await getIt<GetChartsUsecase>().call(param: country);
    result.fold(
      (l) => emit(ChartsFailure(l)),
      (songs) => emit(ChartsLoaded(songs: songs)),
    );
  }
}
