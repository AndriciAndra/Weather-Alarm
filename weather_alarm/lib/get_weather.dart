import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> initLocationService() async {
  var location = Location();
  if (!await location.serviceEnabled()) {
    if (!await location.requestService()) {
      throw Error();
    }
  }

  var permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) {
      throw Error();
    }
  }
  var loc = await location.getLocation();
  print("${loc.latitude} ${loc.longitude}");
  double? lat = loc.latitude;
  double? lon = loc.longitude;

  String apiKey = "7d8a479908c9d53636531b9d2dd2f9dc";
  String domain =
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey";
  http.Response response = await http.get(Uri.parse(domain));
  if (response.statusCode == 200) {
    var decodedData = jsonDecode(response.body);
    String location = decodedData['name'];
    String country = decodedData['sys']['country'];
    int temp = (decodedData['main']['temp'] - 273).toInt();
    var main = decodedData['weather'][0]['main'];
    var wind = decodedData['wind']['speed'];
    String message =
        "The temperature in $location, $country is $temp degrees Celsius, mainly $main and the wind is blowing at a speed of $wind meters per second.";
    return message;
  }
  throw Error();
}
