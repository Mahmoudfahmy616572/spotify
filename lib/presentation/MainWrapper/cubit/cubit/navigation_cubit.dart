import 'package:bloc/bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);
  void updateIndex(int index) {
    emit(index);
  }
}
