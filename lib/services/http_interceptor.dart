import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fiit_mtaa_fe/services/secure_storage.dart';

String _inMemoryToken = '';

class AuthenticatedHttpClient extends http.BaseClient {
  // final StorageService _storageService = StorageService();

  // final prefs = SharedPreferences.getInstance().then((prefs) => prefs);

  // AuthenticatedHttpClient() {
  //   SharedPreferences.getInstance().then((value) => prefs = value);
  // }

  set cachedToken(token) {
    // print('NEW TOKEN: ' + token);
    _inMemoryToken = token;
    SharedPreferences.getInstance().then((prefs) => prefs.setString('token', token));
    // _storageService.writeSecureData('token', token);
  }

  String get userAccessToken {
    if (_inMemoryToken.isNotEmpty) {
      return _inMemoryToken;
    }

    // _inMemoryToken = _loadToken();

    return _inMemoryToken;
  }

  AuthenticatedHttpClient() {
    loadToken();
  }

  get token {
    return _inMemoryToken;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (userAccessToken.isNotEmpty) {
      request.headers.putIfAbsent('cookie', () => 'x-token=' + userAccessToken);
      // request.headers.addAll({ 'x-token': userAccessToken });
      // print('REQ TOKEN: ' + userAccessToken);
    }

    return request.send();
  }

  void loadToken() async {
    // var token = await _storageService.readSecureData('token');
    var token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));

    if (token != null) {
      _inMemoryToken = token;
    }
  }

  void reset() {
    _inMemoryToken = '';
    SharedPreferences.getInstance().then((prefs) => prefs.remove('token'));
    // _storageService.deleteSecureData('token');
  }
}