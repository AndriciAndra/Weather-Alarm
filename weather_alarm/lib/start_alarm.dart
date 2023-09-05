import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:weather_alarm/get_weather.dart';

void oneShotAtTaskCallback(int id, Map<String, dynamic> params) {
  if (params["weather_requested"] == true) {
    var message = params["message"];
    var flutterTts = FlutterTts();
    flutterTts.setVolume(1.0);
    flutterTts.setLanguage("en-US");
    flutterTts.speak(message);
  } else {
    FlutterRingtonePlayer.playAlarm(volume: 0.1, looping: false, asAlarm: true);
    Timer.periodic(const Duration(seconds: 5), (timer) {
      FlutterRingtonePlayer.stop();
      timer.cancel();
    });
  }
}

void alarm(int myId, DateTime date, bool weatherRequested) async {
  String message = await initLocationService();
  Map<String, dynamic> maps = {
    "message": message,
    "weather_requested": weatherRequested
  };
  await AndroidAlarmManager.oneShotAt(date, myId, oneShotAtTaskCallback,
      alarmClock: true, exact: true, params: maps);
}
