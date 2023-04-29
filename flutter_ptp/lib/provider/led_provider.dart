import 'dart:developer';
import 'dart:convert';
// import 'package:app_settings/app_settings.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ptp/utils/constants.dart';
import 'package:location/location.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';

enum NetworkState {
  syncing,
  syncSuccess,
  syncFail,
}

class LedProvider extends ChangeNotifier {
  bool _ledState = false;
  NetworkState _networkState = NetworkState.syncing;

  bool get ledState => _ledState;
  NetworkState get networkState => _networkState;

  Future<void> loadLatestState() async {
    // await Future.delayed(const Duration(milliseconds: 75));
    // _networkState = NetworkState.syncing;
    // notifyListeners();

    if (!await connectToDevice()) {
      await Future.delayed(const Duration(milliseconds: 50));
      _networkState = NetworkState.syncFail;
      notifyListeners();
      return;
    }

    await http
        .get(Uri.http(baseUrl, '/value'))
        .timeout(initialLoadTimeout)
        .then(
      (res) async {
        if (res.statusCode ~/ 2 == 100) {
          final jsn = jsonDecode(res.body) as Map<String, dynamic>;
          if (jsn.containsKey('value')) {
            _ledState = !(jsn['value'].toString() == '0');
            _networkState = NetworkState.syncSuccess;
          } else {
            _networkState = NetworkState.syncFail;
          }
        } else {
          _networkState = NetworkState.syncFail;
        }
      },
      onError: (e, s) {
        log(
          "Fetching value failed!",
          error: e,
          stackTrace: s,
        );
        _networkState = NetworkState.syncFail;
      },
    );
    notifyListeners();
  }

  Future<bool> connectToDevice() async {
    return true;
    final location = Location();
    final locationPermission = await location.requestPermission();
    if (locationPermission != PermissionStatus.granted) {
      return false;
    }

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return false;
    }

    if (!await WiFiForIoTPlugin.isEnabled()) {
      await WiFiForIoTPlugin.setEnabled(true);
      await Future.delayed(const Duration(milliseconds: 66));
      if (!await WiFiForIoTPlugin.isEnabled()) {
        await AppSettings.openWIFISettings();
        if (!await WiFiForIoTPlugin.isEnabled()) return false;
      }
    }

    const ssid = 'IOT-LED';
    const emptyBssid = '02:00:00:00:00:00';
    const bssid = '82:7d:3a:5d:26:b7';
    const password = 'iot02461357';
    final netInfo = NetworkInfo();
    final wifiName = (await netInfo.getWifiName() ?? '').replaceAll('"', '');
    final wifiBssid = await netInfo.getWifiBSSID() ?? '';
    log('Wifi Gateway IP : ${(await netInfo.getWifiGatewayIP())}');
    log('WiFi Name : $wifiName');
    log('WiFi BSSID : $wifiBssid');

    if (!(wifiName == ssid &&
        (wifiBssid == emptyBssid || wifiBssid == bssid))) {
      final isConnected = await WiFiForIoTPlugin.connect(
        ssid,
        bssid: bssid,
        password: password,
        security: NetworkSecurity.WPA,
        isHidden: true,
        joinOnce: true,
        withInternet: false,
        timeoutInSeconds: 10,
      );
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!isConnected) {
        return false;
      }
    }

    return true;
  }

  Future<void> setLedState(bool state) async {
    await Future.delayed(const Duration(milliseconds: 30));
    _networkState = NetworkState.syncing;
    notifyListeners();

    if (!await connectToDevice()) {
      await Future.delayed(const Duration(milliseconds: 50));
      _networkState = NetworkState.syncFail;
      notifyListeners();
      return;
    }

    await http
        .get(
          Uri.http(
            baseUrl,
            '/',
            {'value': state ? '1' : '0'},
          ),
        )
        .timeout(networkTimeout)
        .then(
      (res) async {
        if (res.statusCode ~/ 2 == 100) {
          _ledState = state;
          _networkState = NetworkState.syncSuccess;
        } else {
          _networkState = NetworkState.syncFail;
        }
      },
      onError: (e, s) {
        log(
          "Syncing exception",
          error: e,
          stackTrace: s,
        );
        _networkState = NetworkState.syncFail;
      },
    );
    notifyListeners();
  }

  Future<void> toggleLedState() async => await setLedState(!ledState);
}
