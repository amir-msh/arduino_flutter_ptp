import 'dart:developer';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ptp/utils/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:android_intent_plus/android_intent.dart';

enum NetworkState {
  initial,
  syncing,
  syncSuccess,
  syncFail,
}

class LedProvider extends ChangeNotifier {
  bool _ledState = true;
  NetworkState _networkState = NetworkState.initial;

  bool get ledState => _ledState;
  NetworkState get networkState => _networkState;

  Future<void> loadLatestState() async {
    // await Future.delayed(const Duration(milliseconds: 50));
    // _networkState = NetworkState.syncSuccess;
    // _ledState = true;
    // notifyListeners();

    // await http
    //     .get(
    //       Uri.http(
    //         baseUrl,
    //         '/iot/loglastjson.php',
    //         hoshikalaAuthArguments,
    //       ),
    //     )
    //     .timeout(initialLoadTimeout)
    //     .then(
    //   (res) async {
    //     if (res.statusCode ~/ 2 == 100) {
    //       final jsn = jsonDecode(res.body) as Map<String, dynamic>;
    //       if (jsn.containsKey('ina')) {
    //         _ledState = jsn['ina'] == '0' ? false : true;
    //       }
    //       _networkState = NetworkState.syncSuccess;
    //     } else {
    //       _networkState = NetworkState.syncFail;
    //     }
    //   },
    //   onError: (e, s) {
    //     log(
    //       "Hoshikala fetching exception",
    //       error: e,
    //       stackTrace: s,
    //     );
    //     _networkState = NetworkState.syncFail;
    //   },
    // );
    // notifyListeners();
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

    // AppSettings.openWIFISettings()
    // final connectivityResult = await (Connectivity().checkConnectivity());

    // WiFiForIoTPlugin.connect(STA_DEFAULT_SSID,
    // password: STA_DEFAULT_PASSWORD,
    // joinOnce: true,
    // security: STA_DEFAULT_SECURITY)

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
