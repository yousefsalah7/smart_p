import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'globals.dart' as global;
import 'main.dart';

class GetData {
  static const String _baseUrl =
      'https://learning.masterofthings.com/GetAppReadingValueList';
  static const String _registerUrl =
      'https://learning.masterofthings.com/PostAppData';

  getUserData(username, password) async {
    var response = await Dio().post(
      _registerUrl,
      data: {
        "AppId": 1575,
        "ConditionList": [
          {"Reading": "My_User_Name", "Condition": "e", "Value": username},
          {"Reading": "Password", "Condition": "e", "Value": password}
        ],
        "Auth": {"Key": "NbAwxEltAnGSXqK31651605502141Parking_system_project"}
      },
    );
    // ignore: avoid_print
    //  print(response);

    if (response.statusCode == 200) {
      var parsing = jsonDecode(response.data);
      if (parsing["Info"]["NumberOfReadings"] != 0) {
        var parsedData = parsing['Result'][0]["My_User_Name"];
        return (parsedData);
      }
      return null;
    }
    return response.data;
  }

  getRegisterData(username, password) async {
    var response = await Dio().post(
      _registerUrl,
      data: {
        "AppInfo": {
          "AppId": 1575,
          "SecretKey": "NbAwxEltAnGSXqK31651605502141Parking_system_project"
        },
        "AppData": [
          {
            "My_User_Name": username,
            "Password": password,
          }
        ],
      },
    );
    if (response.statusCode == 200) {
      var parsing = jsonDecode(response.data);
      if (parsing["Info"]["NumberOfReadings"] != 0) {
        var parsedData = parsing['Result'][0]["My_User_Name"];
        return (parsedData);
      }
      return null;
    }
    return null;
  }
  // Check if response is successful

}

class ApiClient {
  final Dio _dio = Dio();

  registerUser(emailController, passwordController) async {
    try {
      Response response = await _dio.post(
        'https://learning.masterofthings.com/PostAppData', //ENDPONT URL
        data: {
          "AppInfo": {
            "AppId": 1575,
            "SecretKey": "NbAwxEltAnGSXqK31651605502141Parking _system_project"
          },
          "AppData": [
            {
              "My_User_Name": " $emailController",
              "Password": "$passwordController",
              "Wallet": 100
            }
          ],
        },
        queryParameters: {
          'apikey': 'NbAwxEltAnGSXqK31651605502141Parking _system_project'
        }, //QUERY PARAMETERS
        //REQUEST BODY
      );
      //returns the successful json object
      return response.data;
    } on DioError catch (e) {
      //returns the error object if there is
      return e.response!.data;
    }
  }

  login(email, password) async {
    try {
      Response response = await _dio.post(
        'https://learning.masterofthings.com/GetAppReadingValueList',
        data: {
          "AppId": 1575,
          "ConditionList": [
            {"Reading": "My_User_Name", "Condition": "e", "Value": " $email"},
            {"Reading": "Password", "Condition": "e", "Value": password}
          ],
          "Auth": {
            "Key": "NbAwxEltAnGSXqK31651605502141Parking _system_project"
          }
        },
        // queryParameters: {
        //   'apikey': 'NbAwxEltAnGSXqK31651605502141Parking _system_project'
        // },
      );
      //returns the successful user data json object
      var parsing = jsonDecode(response.data);
      // MyHomePageState().refresh();
      global.storage.write("userInfo", parsing['Result'][0]["My_User_Name"]);
      global.storage.write("userwallet", parsing['Result'][0]["Wallet"]);
      global.storage.write("userpass", parsing['Result'][0]["Password"]);
      global.storage.write("userId", parsing['Result'][0]["id"]);

      print(parsing['Result'][0]["Wallet"]);
      print(jsonDecode(response.data));
      return jsonDecode(response.data);
    } on DioError catch (e) {
      //returns the error object if any
      return e.response!.data;
    }
  }

  Future<Response> getUserProfileData(String accesstoken) async {
    try {
      Response response = await _dio.get(
        'https://learning.masterofthings.com/GetAppReadingValueList',
        queryParameters: {
          'apikey': 'NbAwxEltAnGSXqK31651605502141Parking_system_project'
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accesstoken',
          },
        ),
      );
      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future<Response> logout(String accessToken) async {
    try {
      Response response = await _dio.get(
        'https://api.loginradius.com/identity/v2/auth/access_token/InValidate',
        queryParameters: {
          'apikey': "NbAwxEltAnGSXqK31651605502141Parking_system_project"
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }
}
