// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class StorageService {
//   final _secureStorage = const FlutterSecureStorage();

//   Future<void> writeSecureData(String key, value) async {
//     await _secureStorage.write(key: key, value: value);
//   }

//   Future<String?> readSecureData(String key) async {
//     var data = await _secureStorage.read(key: key);
//     return data;
//   }

//   Future<void> deleteSecureData(String key) async {
//     await _secureStorage.delete(key: key);
//   }

//   Future<Map<String, String>> readAllSecureData() async {
//     var allData = await _secureStorage.readAll();
//     // List list = allData.entries.map((e) => StorageItem(e.key, e.value)).toList();
//     return allData;
//   }
// }