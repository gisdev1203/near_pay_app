// ignore_for_file: library_private_types_in_public_api, overridden_fields
//ADD ROUTES OF PAGES

class Routes {
  static final _Auth auth = _Auth();
  static final _Home home = _Home();
}

class _Auth extends RouteClass {
  @override
  String module = '/auth';
  String intro = '/';
}

class _Home extends RouteClass {
  @override
  String module = '/home';
  String startPage = '/';
  String login = '/login';
  String actions = '/actions';
}

abstract class RouteClass {
  String module = '/';

  String getRoute(String moduleRoute) => module + moduleRoute;

  String getModule() => '$module/';
}