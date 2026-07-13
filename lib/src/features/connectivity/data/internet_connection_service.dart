import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionService {
  InternetConnectionService(this._connection);

  final InternetConnection _connection;

  Stream<InternetStatus> get onStatusChange => _connection.onStatusChange;

  Future<bool> get hasInternetAccess => _connection.hasInternetAccess;
}
