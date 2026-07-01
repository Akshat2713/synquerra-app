import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/device/device_model.dart';
import '../../../core/error/app_exceptions.dart';

class DeviceRemoteDataSource {
  final DioClient _dioClient;

  DeviceRemoteDataSource(this._dioClient);

  Future<List<DeviceModel>> getDeviceList(String personId) async {
    debugPrint('[DeviceRemoteDataSource] getDeviceList() called for $personId');
    final response = await _dioClient.dio.get(
      ApiConstants.deviceList(personId),
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch devices.',
        statusCode: body['code'] as int?,
      );
    }

    final rawList = body['data'] as List<dynamic>;

    // Parse list off the main thread
    final devices = await Isolate.run(
      () => rawList
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    debugPrint('[DeviceRemoteDataSource] Fetched ${devices.length} devices');

    return devices;
  }
}
