import 'dart:convert';

String convertTagsToJson(List<List<String>> list) {
  // Convert the List<List<String>> to a List<dynamic> for JSON serialization
  List<dynamic> jsonList = list.map((innerList) => innerList).toList();
  
  // Convert the List<dynamic> to a JSON string
  return jsonEncode(jsonList);
}

List<List<String>> convertJsonToTags(String jsonString) {
  // Decode the JSON string into a List<dynamic>
  List<dynamic> jsonList = jsonDecode(jsonString);

  // Convert List<dynamic> to List<List<String>>
  return jsonList.map((innerList) => List<String>.from(innerList)).toList();
}
