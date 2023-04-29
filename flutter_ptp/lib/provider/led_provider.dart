import 'dart:developer';
import 'dart:convert';
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:app_settings/app_settings.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ptp/utils/constants.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import 'package:android_intent_plus/android_intent.dart';

enum NetworkState {
  // initial,
  syncing,
  syncSuccess,
  syncFail,
}

class LedProvider extends ChangeNotifier {
  bool _ledState = false;
  NetworkState _networkState = NetworkState.syncing; // initial

  bool get ledState => _ledState;
  NetworkState get networkState => _networkState;

  Future<void> loadLatestState() async {
    // await Future.delayed(const Duration(milliseconds: 75));
    // _networkState = NetworkState.syncing;
    // notifyListeners();

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

  Future<void> setLedState(bool state) async {
    // {
    //   final deviceInfo = DeviceInfoPlugin();
    //   final androidInfo = await deviceInfo.androidInfo;

    //   if (androidInfo.version.sdkInt >= 29 /*Android Q*/) {
    //     await const AndroidIntent(
    //       action: 'settings.panel.action_wifi',
    //     )
    //         // await const AndroidIntent(action: 'android.settings.SETTINGS')
    //         .launch();

    //     return;
    //   }
    // }

    // await Future.delayed(const Duration(milliseconds: 30));

    // WiFiForIoTPlugin.setEnabled(true);
    // await Future.delayed(const Duration(milliseconds: 30));
    // final connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult != ConnectivityResult.wifi) {
    //   await AppSettings.openWIFISettings();

    //   if ((await Connectivity().checkConnectivity()) !=
    //       ConnectivityResult.wifi) {
    //     return;
    //   }
    // }
    // if (await WiFiForIoTPlugin.getSSID() != 'IOT-LED') {
    //   final isConnected = await WiFiForIoTPlugin.connect(
    //     'IOT-LED',
    //     password: 'iot02461357',
    //     joinOnce: true,
    //     security: NetworkSecurity.WPA,
    //   );

    //   if (!isConnected) return;
    // }

    // WiFiForIoTPlugin.removeWifiNetwork(poCommand.argument);

    _networkState = NetworkState.syncing;
    notifyListeners();

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
