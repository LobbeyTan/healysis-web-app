import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class APIController {
  static const baseUri = "http://127.0.0.1:5000";

  Future<Response?> getData(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    Uri url = Uri.parse(
      "$baseUri$endpoint${params?.entries.map((e) => "${e.key}=${e.value}") ?? ''}",
    );

    Response res = await get(url);

    log(res.body, level: 1);

    return res;
  }

  Future<Response?> postData(
    String endpoint, {
    Map<String, String>? formData,
    Map<String, String>? params,
  }) async {
    Uri url = Uri.parse(
      "$baseUri$endpoint${params?.entries.map((e) => "${e.key}=${e.value}") ?? ''}",
    );

    Response res = await post(url, body: formData);

    log(res.body, level: 1);

    return res;
  }

  Future<Map<String, double>?> predict(String text) async {
    Response? res = await postData("/predict", formData: {'text': text});

    Map<String, double> prediction = {};

    if (res != null) {
      List<dynamic> data = jsonDecode(res.body);

      for (Map<String, dynamic> output in data.first) {
        prediction[output['label']] = output['score'] as double;
      }

      return prediction;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAnalysis() async {
    Response? res = await getData("/analysis");

    if (res != null) {
      Map<String, dynamic> data = jsonDecode(res.body);

      return data;
    }
    return null;
  }
}
