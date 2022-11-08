import 'dart:io';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:smart_p/SettingsPage.dart';
import 'package:smart_p/register.dart';
import 'package:get_storage/get_storage.dart';
import './SigninPage.dart';
import './HomeScreen.dart';
import 'Payment.dart';
import 'globals.dart' as global;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'globals.dart' as global;
import 'SettingsPage.dart';
import 'userTickets.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

var user = global.storage.read("userInfo");
var wallet = global.storage.read("userwallet");

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: (user ?? "Smart Parking pro")),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

MqttServerClient client = MqttServerClient('learning.masterofthings.com', '');
var pongCount = 0;
List<dynamic> myList = [];

class MyHomePageState extends State<MyHomePage> {
  mqttconnect() async {
    client = MqttServerClient('learning.masterofthings.com', '');
    final connMess = MqttConnectMessage()
        .authenticateAs('MoTSensorKitv2.0', 'MoTSensorKitv2.0Pass');
    client.connectionMessage = connMess;
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    print('EXAMPLE::Subscribing to the test/lol topic');
    const topic = 'Phone/01287452627'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      myList.add(pt);
      String helwanAv = myList[0];
      String maadiAv = myList[1];
      global.storage.write("helwanAv", ((helwanAv.trim().length) / 5).floor());
      global.storage.write("maadiAv", ((maadiAv.trim().length) / 5).floor());
      print(myList);
      print(((helwanAv.trim().length) / 5).floor());
      print(((maadiAv.trim().length) / 5).floor());
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    });

    client.published!.listen((MqttPublishMessage message) {
      print(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });
    const pubTopic = 'Phone/Available1';
    const pubTopic2 = 'Phone/Available2';
    print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    client.subscribe(pubTopic, MqttQos.exactlyOnce);
    client.subscribe(pubTopic2, MqttQos.exactlyOnce);
  }

  void publish(String msg) {
    const pubTopic = 'Phone/Available1';

    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  // int _counter = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void refresh() {
    setState(() {
      user = global.storage.read("userInfo");
      wallet = global.storage.read("userwallet");
    });
  }

  String accessToken = 'access_token';
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    mqttconnect();
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.pop(context, true);

    return Scaffold(
        key: _scaffoldKey,
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Color.fromARGB(255, 222, 224, 224),
        appBar: AppBar(
          title: Text("Smart Parking pro"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Payment()));
              },
              child: const Icon(
                Icons.monetization_on_outlined,
                color: Colors.yellowAccent,
                size: 35,
                semanticLabel: "0.0",
              ),
            ),
            Center(
                child: Text(
              global.storage.read("userwallet") != null
                  ? global.storage.read("userwallet").toString()
                  : "0.0",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            )),
            Text("        "),
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: InkWell(
                onTap: () {
                  if (global.storage.read("userInfo") == null) {
                    _pushPage(context, const Register());
                  } else {
                    _signOut(context);
                  }
                },
                child: Center(
                    child: Text(
                  global.storage.read("userInfo") != null
                      ? "Sign out"
                      : "  Sign in \n Register",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                )),
              ),
            )
          ],
        ),
        body: const HomeScreen(),
        endDrawer: SizedBox(
            width: 250,
            child: Drawer(
              elevation: 9,
              backgroundColor: Color.fromARGB(255, 211, 255, 198),
              // Add a ListView to the drawer. This ensures the user can scroll
              // through the options in the drawer if there isn't enough vertical
              // space to fit everything.
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                      height: 284.0,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.green,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle_sharp,
                              color: Color.fromARGB(255, 231, 231, 225),
                              size: 175,
                              semanticLabel: "0.0",
                            ),
                            Text(
                              global.storage.read("userInfo") ?? ".......",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      )),

                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Setting()));
                      },
                      child: Row(
                        children: [
                          Text(
                            "Setting   ",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const Icon(
                            Icons.settings,
                            color: Color.fromARGB(255, 190, 190, 190),
                            size: 35,
                            semanticLabel: "0.0",
                          ),
                        ],
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Ticket()));
                      },
                      child: Row(
                        children: [
                          Text(
                            "Tickets   ",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const Icon(
                            Icons.money,
                            color: Color.fromARGB(255, 209, 208, 208),
                            size: 35,
                            semanticLabel: "0.0",
                          ),
                        ],
                      )),
                  // const SettingsList(
                  // sections: [
                  //     SettingsSection(
                  //       title: Text('Common'),
                  //       tiles: <SettingsTile>[
                  //         SettingsTile.navigation(
                  //           leading: Icon(Icons.language),
                  //           title: Text('Language'),
                  //           value: Text('English'),
                  //         ),
                  //         SettingsTile.switchTile(
                  //           onToggle: (value) {},
                  //           initialValue: true,
                  //           leading: Icon(Icons.format_paint),
                  //           title: Text('Enable custom theme'),
                  //         ),
                  //       ],
                  //     ),
                  // ],
                  // ),
                ],
              ),
            )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 126, 207, 129),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 255, 255, 255),
          onTap: _onTap,
        ));
  }

  _pushPage(BuildContext context, Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _signOut(BuildContext context) {
    global.storage.remove("userwallet");
    global.storage.remove("userInfo");
    refresh();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

// _onTap function
  void _onTap(int index) {
    _selectedIndex = index;
    setState(() {
      _scaffoldKey.currentState!.openEndDrawer();
    });
  }
}
