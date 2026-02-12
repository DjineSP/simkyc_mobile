import 'package:connectivity_plus/connectivity_plus.dart';

abstract class INetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}