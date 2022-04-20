import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:fiit_mtaa_fe/services/secure_storage.dart';
import 'package:fiit_mtaa_fe/services/http_interceptor.dart';
import 'dart:async';
import 'account.dart';
import 'package:fiit_mtaa_fe/config.dart';


// enum Status {
//   NotLoggedIn,
//   NotRegistered,
//   LoggedIn,
//   Registered,
//   Authenticating,
//   Registering,
//   LoggedOut
// }

class AuthProvider with ChangeNotifier {
  // final _storageService = StorageService();
  final httpClient = AuthenticatedHttpClient();

  // Status _loggedInStatus = Status.NotLoggedIn;
  // Status _registeredInStatus = Status.NotRegistered;

  // Status get loggedInStatus => _loggedInStatus;
  // Status get registeredInStatus => _registeredInStatus;

  // Timer _refresher = null!;

  AuthProvider() {
    // _refresher = Timer.periodic(const Duration(minutes: 15), refreshToken);
    // _storageService.deleteSecureData('token');
  }

  refreshToken(Timer t) {
    print('refresh');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    // if (_refresher)
    //   _refresher.cancel();

    final response = await httpClient.post(
      Uri.parse(Config.login),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'username': username, 'password': password })
    );

    if (response.statusCode == 200) {
      var cookie = response.headers['set-cookie'];

      if (cookie != null && cookie.isNotEmpty) {
        Cookie token = Cookie.fromSetCookieValue(cookie);
        httpClient.cachedToken = token.value;
        AccountProvider().token = token.value;
      }

      // _refresher = Timer.periodic(const Duration(minutes: 15), refreshToken);
      // notifyListeners();
      return { 'status': true, 'user': response.body };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  Future<Map<String, dynamic>> register(String username, String name, String password) async {
    // if (_refresher)
    //   _refresher.cancel();

    final response = await httpClient.post(
      Uri.parse(Config.register),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'username': username,
        'name': name,
        'password': password
      })
    );

    if (response.statusCode == 201) {
      var cookie = response.headers['set-cookie'];

      if (cookie != null && cookie.isNotEmpty) {
        Cookie token = Cookie.fromSetCookieValue(cookie);
        httpClient.cachedToken = token.value;
      }

      // _refresher = Timer.periodic(const Duration(minutes: 15), refreshToken);
      // notifyListeners();
      return { 'status': true, 'user': response.body };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  static onError(error) {
    print('the error is $error.detail');
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }

}