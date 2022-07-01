import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Api {
  static String baseUrl = "http://167.99.236.246/bwc/frontend/web/api/scanner";
  static login({
    required String username,
    required String password,
  }) async {
    var response = await http.post(
        Uri.parse(
          "$baseUrl/login",
        ),
        body: {
          "username": username,
          "password": password,
        });

    return response;
  }

  static getSocieties() async {
    try {
      var response = await http.get(
        Uri.parse("$baseUrl/get-societies"),
      );
      return response;
    } on SocketException {
      throw const SocketException("No internet");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static getSocietyInformation(code, id, token) async {
    try {
      var response = await http
          .get(Uri.parse("$baseUrl/scancode?$code&society_id=$id"), headers: {
        "last_login_token": token,
      });

      return response;
    } on SocketException {
      throw const SocketException("No internet");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static getImages(String token, String id) async {
    try {
      var response = await http
          .get(Uri.parse("$baseUrl/existing-images?file_id=$id"), headers: {
        "last_login_token": token,
      });

      return response;
    } on SocketException {
      throw const SocketException("No internet");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static getThumb(String token, String id) async {
    try {
      var response = await http.get(
          Uri.parse("$baseUrl/get-thumb-member-data?file_id=$id"),
          headers: {
            "last_login_token": token,
          });

      return response;
    } on SocketException {
      throw const SocketException("No internet");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
