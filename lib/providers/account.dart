import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fiit_mtaa_fe/services/http_interceptor.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:fiit_mtaa_fe/config.dart';
import 'package:jwt_decode/jwt_decode.dart';

Map<String, dynamic> decriptedToken = {};

class AccountProvider with ChangeNotifier {
  final httpClient = AuthenticatedHttpClient();
  final ImagePicker _picker = ImagePicker();

  set token(token) {
    if (token == null) {
      decriptedToken = {};
      httpClient.reset();
    } else {
      decriptedToken = Jwt.parseJwt(token);
    }
  }

  get token {
    return decriptedToken;
  }

  onError() {
    return;
  }

  Future<Map<String, dynamic>> changeAvatar() async {
    PickedFile? image;
    try {
      image = await _picker.getImage(source: ImageSource.gallery);
    } catch(ex) {
      print(ex);
      return { 'status': false, 'message': 'Failed to read image' };
    }

    if (image == null) {
      return { 'status': false, 'message': 'Failed to read image' };
    }

    var splittedPath = image.path.split('.');
    var type = splittedPath[splittedPath.length - 1];
    var bytes = await image.readAsBytes();

    final response = await httpClient.post(
      Uri.parse(Config.avatar),
      headers: { 'Content-Type': 'image/$type' },
      body: bytes
    );

    if (response.statusCode == 201) {
      return { 'status': true };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final response = await httpClient.put(
      Uri.parse(Config.changePassword),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'oldPassword': oldPassword, 'newPassword': newPassword })
    );

    if (response.statusCode == 200) {
      var cookie = response.headers['set-cookie'];

      if (cookie != null && cookie.isNotEmpty) {
        Cookie token = Cookie.fromSetCookieValue(cookie);
        httpClient.cachedToken = token.value;
        this.token = token.value;
      }

      return { 'status': true };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final response = await httpClient.delete(Uri.parse(Config.deleteAccount));

    if (response.statusCode == 200) {
      decriptedToken = {};
      httpClient.reset();

      return { 'status': true };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

}