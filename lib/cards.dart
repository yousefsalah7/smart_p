// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_p/userTickets.dart';

import 'main.dart';
import 'dart:async';

import 'dart:math';
import 'package:dio/dio.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'globals.dart' as global;
import 'package:location/location.dart' as local;
import 'package:flutter_email_sender/flutter_email_sender.dart';

final Dio _dio = Dio();

class PlaceMarkerBody extends StatefulWidget {
  const PlaceMarkerBody({Key? key}) : super(key: key);

  @override
  _PlaceMarkerBodyState createState() => _PlaceMarkerBodyState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  local.LocationData? _locationData;
  TimeOfDay selectedTime = TimeOfDay.now();
  var startlat;
  var startlon;
  var dislat;
  var dislon;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  late Position _currentPosition;
  MqttServerClient client = MqttServerClient('broker.emqx.io', '42254');
  _getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      bool servicestatus = await local.Location().serviceEnabled();
      if (servicestatus) {
        _locationData = await local.Location().getLocation();
        print(_locationData);
        startlat = _locationData!.latitude;
        startlon = _locationData!.longitude;
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

    client = MqttServerClient('broker.emqx.io', '54552254');
    const pubTopic = '01287452627';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client gowaaa');
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');
        // startlat = position.latitude;
        // startlon = position.longitude;
        // For moving the camera to current location
        controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                bearing: 192.8334901395799,
                tilt: 59.440717697143555,
                zoom: 18.151926040649414),
          ),
        );
      });
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "put your google map api key", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      travelMode: TravelMode.driving,
    );
    print(result.points);
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    print(polylineCoordinates);
    // Defining an ID
    PolylineId id = const PolylineId('poly');
    setState(() {
      // Initializing Polyline
      Polyline polyline = Polyline(
        visible: true,
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 7,
      );
      polylines[id] = polyline;
    });
    // Adding the polyline to the map
  }

  _PlaceMarkerBodyState();
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  GoogleMapController? controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    final marker = Marker(
        markerId: const MarkerId('12603'),
        position: const LatLng(29.85928475824479, 31.31865538330037),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'Ain Helwan',
          snippet: 'Avilable: 24 ',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12603'), 29.85928475824479, 31.31865538330037),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12603'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12603'), position));
    final marker1 = Marker(
        markerId: const MarkerId('12604'),
        position: const LatLng(29.908488768182043, 31.298998336129852),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'ALma3sara',
          snippet: 'Avilable: 12 ',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12604'), 29.908488768182043, 31.298998336129852),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12604'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12604'), position));

    final marker2 = Marker(
        markerId: const MarkerId('12605'),
        position: const LatLng(29.409169218143916, 31.252595269025882),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'AtfeeH',
          snippet: 'Avilable: 6 ',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12605'), 29.409169218143916, 31.252595269025882),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12605'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12605'), position));
    final marker3 = Marker(
        markerId: const MarkerId('12606'),
        position: const LatLng(30.14403166942635, 31.418146647789783),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'ALHaikstep',
          snippet: 'Avilable: 21 ',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12606'), 30.14403166942635, 31.418146647789783),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12606'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12606'), position));
    final marker4 = Marker(
        markerId: const MarkerId('12607'),
        position: const LatLng(29.57825297361779, 31.29460171126989),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'AL_Saaf',
          snippet: 'Avilable: 17',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12607'), 29.57825297361779, 31.29460171126989),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12607'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12607'), position));
    final marker5 = Marker(
        markerId: const MarkerId('12608'),
        position: const LatLng(30.140457420040292, 31.632042615927446),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'ALShrouk',
          snippet: 'Avilable: 31',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('12608'), 30.140457420040292, 31.632042615927446),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('12608'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('12608'), position));
    setState(() {
      markers[const MarkerId('12603')] = marker;
      markers[const MarkerId('12604')] = marker1;
      markers[const MarkerId('12605')] = marker2;
      markers[const MarkerId('12606')] = marker3;
      markers[const MarkerId('12607')] = marker4;
      markers[const MarkerId('12608')] = marker5;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId, lat, lng) {
    final CameraPosition _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 15.151926040649414);

    controller!.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }

    dislat = lat;
    dislon = lng;
    print("dis laaaat" + dislat);
    print("dis looon " + dislon);
  }

  List<String> attachments = [];
  bool isHTML = false;
  final Dio _dio = Dio();
  Future<void> send(useremail, w2t, tzkaraa) async {
    try {
      Response response = await _dio
          .post('https://api.emailjs.com/api/v1.0/email/send', //ENDPONT URL
              data: {
            "service_id": "service_upp8nbq",
            "template_id": "template_yj153se",
            "user_id": "0y5BpNGkB3V3V8u1J",
            "template_params": {
              "useremail": useremail,
              "to_name": useremail,
              "message": w2t,
              "message2": tzkaraa
            }
          }
              //REQUEST BODY
              );
      //returns the successful json object
      return response.data;
    } on DioError catch (e) {
      //returns the error object if there is
      return e.response!.data;
    }
  }

  UpdateBalance(int nBalance, int id) async {
    print("FFFFFFFFFFFFFFFFFFFFFF ");
    try {
      Response response = await _dio.post(
        'https://learning.masterofthings.com/PostSensorData', //ENDPONT URL
        data: {
          "Package": {
            "SensorInfo": {"SensorId": 12736},
            "SensorData": {"wallet": nBalance, "car_id": id}
          },
          "Auth": {"DriverManagerId": "1", "DriverManagerPassword": "123"}
        }, //QUERY PARAMETERS
        //REQUEST BODY
      );
      //returns the successful json object
      return response.data;
    } on DioError catch (e) {
      //returns the error object if there is
      return e.response!.data;
    }
  }

  updateTickets(dynamic name, int ticket, String time, sensor, userId) async {
    print("FFFFFFFFFFFFFFFFFFFFFF ");
    try {
      Response response = await _dio.post(
        'https://learning.masterofthings.com/PostSensorData', //ENDPONT URL
        data: {
          "Package": {
            "SensorInfo": {"SensorId": 12887},
            "SensorData": {
              "Name": name,
              "Ticket": ticket,
              "bookingFor": time,
              "SensorID": sensor,
              "booked_User_ID": userId
            }
          },
          "Auth": {"DriverManagerId": "1", "DriverManagerPassword": "123"}
        }, //QUERY PARAMETERS
        //REQUEST BODY
      );
      //returns the successful json object
      return response.data;
    } on DioError catch (e) {
      //returns the error object if there is
      return e.response!.data;
    }
  }

  Future<void> _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      markerPosition = newPosition;
    });
  }

  Future<void> _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        markerPosition = null;
      });
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  Future<void> _toggleFlat(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        flatParam: !marker.flat,
      );
    });
  }

  Future<void> _changeAlpha(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.alpha;
    setState(() {
      markers[markerId] = marker.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _changeRotation(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.rotation;
    setState(() {
      markers[markerId] = marker.copyWith(
        rotationParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }

  Future<void> _toggleVisible(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        visibleParam: !marker.visible,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final MarkerId? selectedId = selectedMarker;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 211, 240, 198),
        body: Stack(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: GoogleMap(
                  myLocationEnabled: true,
                  mapType: MapType.hybrid,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(29.840641543740777, 31.301189504192617),
                    zoom: 9.6,
                  ),
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed:
                        selectedId == null ? null : () => _showDialog(true),
                    child: const Text('BOOK NOW'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: selectedId == null
                        ? null
                        : () => _createPolylines(
                            startlat, startlon, dislat, dislon),
                    child: const Text('Distination'),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: selectedId == null
                        ? null
                        : () => _changeAlpha(selectedId),
                    child: const Text('change alpha'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: selectedId == null
                        ? null
                        : () => _toggleFlat(selectedId),
                    child: const Text('toggle flat'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: selectedId == null
                        ? null
                        : () => _changeRotation(selectedId),
                    child: const Text('change rotation'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      // onPrimary: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 185, 66),
                      onSurface: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 241, 202, 72),
                      elevation: 15,

                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255), width: 1),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: selectedId == null
                        ? null
                        : () => _toggleVisible(selectedId),
                    child: const Text('toggle visible'),
                  ),
                ],
              ),
            ],
          ),
          Visibility(
            visible: markerPosition != null,
            child: Container(
              // decoration: BoxDecoration(
              //     color: Colors.yellow,
              //     border: Border.all(
              //       color: Theme.of(context).colorScheme.secondary,
              //     )),
              color: const Color.fromARGB(179, 189, 26, 26),
              height: 30,
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  if (markerPosition == null)
                    Container()
                  else
                    Expanded(child: Text('lat: ${markerPosition!.latitude}')),
                  if (markerPosition == null)
                    Container()
                  else
                    Expanded(child: Text('lng: ${markerPosition!.longitude}')),
                ],
              ),
            ),
          ),
        ]));
  }

  final TextEditingController _passwordController =
      TextEditingController(text: "");

  dynamic _showDialog(bool isBooked) {
    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      print(picked_s);
      if (picked_s != null && picked_s != selectedTime) {
        setState(() {
          selectedTime = picked_s;
        });
      }
      Navigator.of(context).pop();
      _showDialog(true);
    }

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    AlertDialog alert = AlertDialog(
      title: const Text("Enter your account password:"),
      content: Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _selectTime(context);
            },
            child: const Text('SELECT TIME'),
          ),
          const SizedBox(height: 8),
          Text(
            'Selected time: ${selectedTime.format(context)}',
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
              },
            ),
          ),
          const SizedBox(height: 30),
          FloatingActionButton(
            onPressed: () {
              dynamic ID = global.storage.read("userId");
              dynamic pass = global.storage.read("userpass");
              dynamic wallet = global.storage.read("userwallet");
              if (pass == _passwordController.text) {
                print("PAssword Matched");
                MyHomePageState()
                    .publish(selectedMarker.toString().substring(9, 14));
                dynamic newbalance = wallet - 10;
                global.storage.write("userwallet", newbalance);
                UpdateBalance(newbalance, ID);
                _showDialog2();
              } else {
                const snackBar = SnackBar(
                  content: Text('Yay! A SnackBar!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "Incorrect Password",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: Text(isBooked ? "Book" : "UnBook"),
          )
        ],
      )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  dynamic _showDialog2() {
    Random random = Random();
    var _randomNumber1 = random.nextInt(954236);
    dynamic namme = global.storage.read("userInfo");
    send(namme, selectedTime.format(context).toString(), _randomNumber1);
    Movie().addTiket(
        _randomNumber1.toString(), selectedTime.format(context).toString());
    updateTickets(
        namme,
        _randomNumber1,
        selectedTime.format(context).toString(),
        selectedMarker.toString().substring(9, 14),
        global.storage.read("userId").toString());
    AlertDialog alert = AlertDialog(
      title: const Text(
        "  Your Ticket number is :",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      // ignore: avoid_unnecessary_containers
      content: Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _randomNumber1.toString(),
            style: const TextStyle(
                color: const Color.fromARGB(255, 45, 24, 70),
                fontWeight: FontWeight.w900,
                fontSize: 35),
          ),
          const Text(""),
          const Text(
            "PlZz keep it \n show it while Asked",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
            child: const Text("OK"),
          )
        ],
      )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//
}
