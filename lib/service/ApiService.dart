import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'appexception.dart';

class ApiService {
  static final String BASE_URL = 'https://ga9uj8f89i.execute-api.ap-south-1.amazonaws.com/Prod';

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(Uri.encodeFull(BASE_URL + url), headers: {"Accept":"application/json"});
      print(response);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Connectivity');
    } catch(e) {
      print(e.toString());
      throw Exception();
    }
    return responseJson;
  }

  Future<dynamic> post(String url, String body) async {
    var responseJson;
    try {
      final response = await http.post(BASE_URL + url, body: body);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Connectivity');
    } catch (e) {
      print(e);
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        var res = ApiExceptionMessage.fromJson(json.decode(response.body));
        throw FetchDataException(res.message);
    }
  }
}

class ApiExceptionMessage {
  String timestamp;
  String message;

  ApiExceptionMessage({this.timestamp, this.message});

  ApiExceptionMessage.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['message'] = this.message;
    return data;
  }
}
