import 'dart:async';
import 'package:flutterstore/repository/token_repository.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/api_status.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/provider/common/ps_provider.dart';
import 'package:flutter/cupertino.dart';

class TokenProvider extends PsProvider {
  TokenProvider({@required TokenRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('Token Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }

  TokenRepository _repo;
  @override
  void dispose() {
    isDispose = true;
    print('Token Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadToken() async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
      final PsResource<ApiStatus> _resource = await _repo.getToken(isConnectedToInternet, PsStatus.SUCCESS);
     return _resource;
  }
}
