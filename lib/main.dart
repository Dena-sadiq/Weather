import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int ? temperature;
  String location = 'Baghdad';
  int woeid = 2487956;
  String weather = 'clear';
  String abbrevation = '';
  String errorMgs= "";


  final position =  Geolocator.getCurrentPosition(forceAndroidLocationManager: true);

  late Position _currentPosition;
  // late String _currentAddress;

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';


  @override
  initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMgs = "";
      });
    }

    catch(error) {
      setState(() {
        errorMgs = "Error.. nothing to show, Please try another city.";
      });
    }
  }


  Future<void> fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbrevation = data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();
  }
  // _getCurrentLocation() {
  //   geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //     });
  //
  //     _getAddressFromLatLng();
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }
  //
  // _getAddressFromLatLng() async {
  //   try {
  //     List<Placemark> p = await geolocator.placemarkFromCoordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);
  //
  //     Placemark place = p[0];
  //
  //     setState(() {
  //       _currentAddress =
  //       "${place.locality}, ${place.postalCode}, ${place.country}";
  //     });
  //     onTextFieldSubmitted(place.locality);
  //     print(place.locality);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/$weather.png'),
          fit: BoxFit.cover,
        ),
      ),
          child: temperature == null ? const Center( child: CircularProgressIndicator())
          : Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {_currentPosition;},
                    child: const Icon(Icons.location_city , size: 36.0),
                  ),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0.0 ,
            ),
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/'+ abbrevation +'.png',
                          width: 100,
                        ),
                      ),
                      Center(
                        child: Text(
                          temperature.toString() + ' °C',
                          style: const TextStyle(color: Colors.white, fontSize: 60),
                        ),
                      ),
                      Center(
                        child: Text(
                          location,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 40),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onSubmitted: (String input) {
                            onTextFieldSubmitted(input);
                          },
                          style: const TextStyle(
                              color: Colors.white, fontSize: 25),
                          decoration: const InputDecoration(
                              hintText: 'Search another location...',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                          ),
                        ),
                      ),
                      Text(
                        errorMgs,textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,fontSize: Platform.isAndroid ? 15.0 : 20.0
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    ),
    );
  }
}
