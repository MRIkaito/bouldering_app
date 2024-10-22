import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/model/my_home_model.dart';

// reverpodのStateNotifierProviderを利用
final myHomePageProvider =
    StateNotifierProvider<MyHomePageViewModel, MyHomePageModel>(
        (ref) => MyHomePageViewModel());

class MyHomePageViewModel extends StateNotifier<MyHomePageModel> {
  MyHomePageViewModel() : super(const MyHomePageModel());

  void updateCounter() {
    state = state.updateCounter(state.counter);
  }
}
