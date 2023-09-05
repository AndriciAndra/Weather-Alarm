import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:weather_alarm/start_alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  WeatherAlarm createState() => WeatherAlarm();
}

class WeatherAlarm extends State<MyApp> {
  List<Tuple3<TimeOfDay, DateTime, bool>> dateTimes = [];
  Set<Tuple3<TimeOfDay, DateTime, bool>> setDateTimes = {};

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  int mySort(Tuple3<TimeOfDay, DateTime, bool> a,
      Tuple3<TimeOfDay, DateTime, bool> b) {
    int result = toDouble(a.item1).compareTo(toDouble(b.item1));
    if (result == 0) {
      return a.item2.compareTo(b.item2);
    }
    return result;
  }

  Future<TimeOfDay?> pickTime() async {
    return await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 00),
    );
  }

  Future<DateTime?> pickDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  String getDate(index) {
    String date = DateFormat.MMMEd().format(dateTimes[index].item2);
    if (dateTimes[index].item2.year > DateTime.now().year) {
      date = DateFormat.yMMMEd().format(dateTimes[index].item2);
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6),
          title: const Text("Weather Alarm",
              style: TextStyle(
                  color: Color(0xFF333333), fontWeight: FontWeight.bold)),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? newTime = await pickTime();
                      if (newTime == null) return;
                      DateTime? newDate = await pickDate();
                      if (newDate == null) return;
                      setState(() {
                        var newAlarm = Tuple3(newTime, newDate, false);
                        setDateTimes.add(newAlarm);
                        dateTimes.add(newAlarm);
                        DateTime date = DateTime(newDate.year, newDate.month,
                            newDate.day, newTime.hour, newTime.minute);
                        alarm(dateTimes.length, date, newAlarm.item3);
                      });
                    },
                    child: const Icon(
                      Icons.add,
                      size: 30.0,
                      color: Color(0xFF333333),
                    )))
          ],
        ),
        body: ListView.builder(
            itemCount: dateTimes.length,
            itemExtent: 100.0,
            padding: const EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int index) {
              dateTimes.sort(mySort);
              return Padding(
                  padding: const EdgeInsets.fromLTRB(2, 5, 2, 7),
                  child: Container(
                      decoration: const BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color(0x33333333),
                              offset: Offset(0, 0),
                              blurRadius: 10.0,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(children: [
                                Text(
                                  dateTimes[index].item1.format(context),
                                  style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                                Text(
                                  getDate(index),
                                  style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                )
                              ]),
                              const Text("weather ringtone"),
                              Switch(
                                value: dateTimes[index].item3,
                                onChanged: (bool? value) {
                                  setState(() {
                                    dateTimes[index] = Tuple3(
                                        dateTimes[index].item1,
                                        dateTimes[index].item2,
                                        !dateTimes[index].item3);
                                    AndroidAlarmManager.cancel(index);
                                    DateTime date = DateTime(
                                        dateTimes[index].item2.year,
                                        dateTimes[index].item2.month,
                                        dateTimes[index].item2.day,
                                        dateTimes[index].item1.hour,
                                        dateTimes[index].item1.minute);
                                    alarm(index + 1, date, true);
                                  });
                                },
                                activeTrackColor: Colors.lightBlueAccent,
                                activeColor: Colors.blue,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      AndroidAlarmManager.cancel(
                                          dateTimes.length);
                                      setDateTimes.remove(dateTimes[index]);
                                      dateTimes.removeAt(index);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Color(0xFF333333),
                                  ))
                            ]),
                      ])));
            }));
  }
}
