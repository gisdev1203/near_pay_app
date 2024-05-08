import 'package:get_it/get_it.dart';
import 'package:near_pay_app/network/api_service.dart';


final GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<ApiService>(ApiService());
  //Add more dependicies like near blockchain service crypto service js engines integration payment etc..
}
