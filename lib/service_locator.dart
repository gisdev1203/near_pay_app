import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';
import 'package:near_pay_app/core/models/vault.dart';
import 'package:near_pay_app/data/network/account_service.dart';
import 'package:near_pay_app/presantation/utils/biometrics.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';


GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<AccountService>(() => AccountService());
  sl.registerLazySingleton<DBHelper>(() => DBHelper());
  sl.registerLazySingleton<BiometricUtil>(() => BiometricUtil());
  sl.registerLazySingleton<Vault>(() => Vault());
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<Logger>(() => Logger('NearPayApp'));
}