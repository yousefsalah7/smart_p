// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './DetailsScreen.dart';
import './SigninPage.dart';
import 'cards_helwan.dart';
import 'getData.dart';
import 'globals.dart' as global;
import 'dart:math' show cos, sqrt, asin;
import 'package:geolocator/geolocator.dart';
import 'cards.dart';
import 'package:location/location.dart' as local;
import 'package:permission_handler/permission_handler.dart';

final user = global.storage.read("userInfo");

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  local.LocationData? _locationData;
  @override
  void initState() {
    super.initState();
    takePermissions(29.840641543740777, 29.962257844890928, 31.301189504192617,
        31.317037617109488);
  }

  // ignore: prefer_typing_uninitialized_variables
  var helwanPosition;
  // ignore: prefer_typing_uninitialized_variables
  var maadiPosition;

  takePermissions(lat1, lat2, lon1, lon2) async {
    if (await Permission.location.request().isGranted) {
      bool servicestatus = await local.Location().serviceEnabled();
      if (servicestatus) {
        _locationData = await local.Location().getLocation();
        print(_locationData);
        var lat = _locationData!.latitude;
        var long = _locationData!.longitude;

        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 -
            c((lat! - lat1) * p) / 2 +
            c(lat1 * p) * c(lat * p) * (1 - c((long! - lon1) * p)) / 2;
        var b = 0.5 -
            c((lat - lat2) * p) / 2 +
            c(lat2 * p) * c(lat * p) * (1 - c((long - lon2) * p)) / 2;
        var helwanDistance = 12742 * asin(sqrt(a));
        var maadiDistance = 12742 * asin(sqrt(b));
        print(helwanDistance.floor() / 1000);
        print(maadiDistance.floor() / 1000);
        helwanPosition = helwanDistance.floor();
        maadiPosition = maadiDistance.floor();
        setState(() {
          helwanPosition = helwanDistance.floor();
          maadiPosition = maadiDistance.floor();
        });
      } else {
        print("GPS service is disabled.");

        if (await local.Location().requestService()) {
          _locationData = await local.Location().getLocation();
        } else {
          SystemNavigator.pop();
        }
      }
    }
    if (await Permission.location.isDenied) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color.fromARGB(255, 211, 255, 198),
            body: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 0, top: 50, right: 0, bottom: 25),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        handleGridItemClick(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "HelWaN",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 10 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                "Available: " +
                                    global.storage.read("helwanAv").toString() +
                                    "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 5 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                helwanPosition.toString() == "null"
                                    ? "Loading...."
                                    : (helwanPosition.toString() + " Km "),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                    const Text(""),
                    InkWell(
                      onTap: () {
                        handleGridItemClick2(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "MAaDI",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 25 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                "Available: " +
                                    global.storage.read("maadiAv").toString() +
                                    "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 4 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                (maadiPosition.toString() == "null"
                                    ? "Loading...."
                                    : maadiPosition.toString() + " Km "),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                    const Text(""),
                    InkWell(
                      onTap: () {
                        handleGridItemClick(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "NasR city",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 25 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            const Text("Available: " + "12" + "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 10 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                (maadiPosition.toString() == "null"
                                    ? "Loading...."
                                    : "30 Km"),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                    const Text(""),
                    InkWell(
                      onTap: () {
                        handleGridItemClick(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "OCtober",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 30 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            const Text("Available: " + "9" + "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 13 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                (maadiPosition.toString() == "null"
                                    ? "Loading...."
                                    : " 44 Km"),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                    const Text(""),
                    InkWell(
                      onTap: () {
                        handleGridItemClick(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "ZamaLik",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 35 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text("Available: " + "7" + "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 22 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                (maadiPosition.toString() == "null"
                                    ? "Loading...."
                                    : " 42 Km"),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                    const Text(""),
                    InkWell(
                      onTap: () {
                        handleGridItemClick(context);
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "MaRg",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.green),
                            ),
                            const Text(""),
                            const Text(" 15 EGP / Hour",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            const Text("Available: " + "14" + "  Slots",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text("Occupied: 9 Slots ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 29, 28, 28))),
                            const Text(""),
                            Text(
                                (maadiPosition.toString() == "null"
                                    ? "Loading...."
                                    : "38 Km"),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 92, 31, 31))),
                          ],
                        ),
                      ),
                    ),
                  ],
                )))));
  }

  void handleGridItemClick(BuildContext context) async {
    print(helwanPosition);

    if (global.storage.read("userInfo") != null) {
      print("user authenticated");

      _pushPage(context, const PlaceMarkerBody());
    } else {
      print("user is not authorised");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(
            label: "Sign in // up",
            disabledTextColor: Colors.grey,
            textColor: Colors.white,
            onPressed: () {
              _pushPage(context, const SigninPage());
            }),
        content: const Text(
          "Please sign up/ sign in",
          style: TextStyle(
              color: Color.fromARGB(255, 228, 221, 221), fontSize: 22),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(255, 116, 3, 3),
      ));
    }
  }

  void handleGridItemClick2(BuildContext context) async {
    print(helwanPosition);

    if (global.storage.read("userInfo") != null) {
      print("user authenticated");

      _pushPage(context, const PlaceMarkerBody2());
    } else {
      print("user is not authorised");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(
            label: "Sign in // up",
            disabledTextColor: Colors.grey,
            textColor: Colors.white,
            onPressed: () {
              _pushPage(context, const SigninPage());
            }),
        content: const Text(
          "Please sign up/ sign in",
          style: TextStyle(
              color: Color.fromARGB(255, 228, 221, 221), fontSize: 22),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(255, 116, 3, 3),
      ));
    }
  }

  void _pushPage(BuildContext context, Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
