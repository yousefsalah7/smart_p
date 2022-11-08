// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// class PlaceMarkerPage extends  StatefulWidget {

//    const PlaceMarkerPage({Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const PlaceMarkerBody();
//   }
// }

class PlaceMarkerBody2 extends StatefulWidget {
  const PlaceMarkerBody2({Key? key}) : super(key: key);

  @override
  _PlaceMarkerBody2State createState() => _PlaceMarkerBody2State();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _PlaceMarkerBody2State extends State<PlaceMarkerBody2> {
  var startlat;
  var startlon;
  var dislat;
  var dislon;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   _loadDataAndNavigate();
    // });
  }

  // _loadDataAndNavigate() async {
  //   // fetch data | await this.service.fetch(x,y)
  //   Navigator.of(context).pushNamed('/');
  // }

  late Position _currentPosition;
  MqttServerClient client = MqttServerClient('broker.emqx.io', '42254');
  _getCurrentLocation() async {
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
        startlat = position.latitude;
        startlon = position.longitude;
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
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
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

  _PlaceMarkerBody2State();
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
        markerId: const MarkerId('Ain Helwan'),
        position: const LatLng(29.957832080708783, 31.25074982584001),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'Kornesh Al neil',
          snippet: 'Avilable: 31',
        ),
        onTap: () => _onMarkerTapped(const MarkerId('Ain Helwan'),
            29.957832080708783, 31.25074982584001),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('Ain Helwan'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('Ain Helwan'), position));
    final marker1 = Marker(
        markerId: const MarkerId('ALma3sara'),
        position: const LatLng(29.9835703137357, 31.31630641049916),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'City center',
          snippet: 'Avilable: 24',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('ALma3sara'), 29.9835703137357, 31.31630641049916),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('ALma3sara'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('ALma3sara'), position));

    final marker2 = Marker(
        markerId: const MarkerId('AtfeeH'),
        position: const LatLng(29.978322880002512, 31.281178441181872),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'New Maadi',
          snippet: 'Avilable: 14',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('AtfeeH'), 29.978322880002512, 31.281178441181872),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('AtfeeH'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('AtfeeH'), position));
    final marker3 = Marker(
        markerId: const MarkerId('ALHaikstep'),
        position: const LatLng(29.962735018357264, 31.30545073105289),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'Zahraa Almaadi',
          snippet: 'Avilable: 26',
        ),
        onTap: () => _onMarkerTapped(const MarkerId('ALHaikstep'),
            29.962735018357264, 31.30545073105289),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('ALHaikstep'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('ALHaikstep'), position));
    final marker4 = Marker(
        markerId: const MarkerId('AL_Saaf'),
        position: const LatLng(29.973125649234678, 31.304502312346393),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'AL_meArag',
          snippet: 'Avilable: 15',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('AL_Saaf'), 29.973125649234678, 31.304502312346393),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('AL_Saaf'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('AL_Saaf'), position));
    final marker5 = Marker(
        markerId: const MarkerId('ALShrouk'),
        position: const LatLng(29.960346075535952, 31.25700171234611),
        // icon: BitmapDescriptor.,
        infoWindow: const InfoWindow(
          title: 'Arab Maadi',
          snippet: 'Avilable: 11',
        ),
        onTap: () => _onMarkerTapped(
            const MarkerId('ALShrouk'), 29.960346075535952, 31.25700171234611),
        onDragEnd: (LatLng position) =>
            _onMarkerDragEnd(const MarkerId('ALShrouk'), position),
        onDrag: (LatLng position) =>
            _onMarkerDrag(const MarkerId('ALShrouk'), position));
    setState(() {
      markers[const MarkerId('Ain Helwan')] = marker;
      markers[const MarkerId('ALma3sara')] = marker1;
      markers[const MarkerId('AtfeeH')] = marker2;
      markers[const MarkerId('ALHaikstep')] = marker3;
      markers[const MarkerId('AL_Saaf')] = marker4;
      markers[const MarkerId('ALShrouk')] = marker5;
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

  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () =>
          _onMarkerTapped(markerId, 30.140457420040292, 31.632042615927446),
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
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
                    target: LatLng(29.964191181107097, 31.263307609633245),
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
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    AlertDialog alert = AlertDialog(
      title: Text("Enter your account password:"),
      content: Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                if (value.length <= 6) {
                  return 'Please enter atleast 6 characters long password';
                }
              },
            ),
          ),
          const SizedBox(height: 30),
          FloatingActionButton(
            onPressed: () async {
              if (true) {
                // String encryptedPassword;

                // var user;
                // await Firestore.instance
                //     .collection("parkingSlotsPassword")
                //     .document(user.uid)
                //     .get()
                //     .then((value) {
                //   encryptedPassword = value.data['password'];
                // });
                dynamic pass = "";

                if (pass == ("_passwordController.text" + "@1234!")) {
                  print("PAssword Matched");
                  if (isBooked) {
                    // book();
                  } else {
                    // unbook();
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Incorrect Password",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    backgroundColor: Colors.green,
                  ));
                }
              }
            },
            child: Text(isBooked ? "Book" : "UnBook"),
          )
        ],
      )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.all(20),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//     final connMess = MqttConnectMessage()
//         .withClientIdentifier('mqttx_19ad3944')
// // If you set this you must set a will message
//         .authenticateAs("", "") // Non persistent session for testing
//         .startClean()
//         .withWillQos(MqttQos.atMostOnce);

//     print('EXAMPLE::Mosquitto client connecting....');
//     client.connectionMessage = connMess;

  // if (client.connectionStatus!.state == MqttConnectionState.connected) {
  //   print('EXAMPLE::Mosquitto client connected');
  // } else {
  //   /// Use status here rather than state if you also want the broker return code.
  //   print(
  //       'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
  //   client.disconnect();
  //   // exit(-1);
  // }
  // const topic = '01287452627'; // Not a wildcard topic
  // client.subscribe(topic, MqttQos.atMostOnce);
  // client.onSubscribed = onSubscribed;
  // client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //   final recMess = c![0].payload as MqttPublishMessage;
  //   final pt =
  //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //   print(
  //       'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
  //   // Timer(Duration(seconds: 1), () => {_addMarker(pt), _addBar(pt)});

  //   print('Connected');
  // });

  //

}
