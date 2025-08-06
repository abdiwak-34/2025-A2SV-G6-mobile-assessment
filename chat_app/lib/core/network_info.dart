import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter/foundation.dart';


import '../core/error/exeception.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker dataConnectionChecker;

  NetworkInfoImpl(this.dataConnectionChecker);

  @override
  Future<bool> get isConnected async {
   return dataConnectionChecker.hasConnection;
  }
}
