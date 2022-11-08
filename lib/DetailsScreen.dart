import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final String location;
  const DetailsScreen(this.location, {Key? key}) : super(key: key);
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class ParkingSlot {
  final int location;
  final bool isOccupied;
  bool isSelected;
  ParkingSlot(
      {required this.location,
      required this.isOccupied,
      required this.isSelected});
}

final int totalSize = 20;
final int numberOfTowers = 2;
final int numberOfParkingSlotsInEachTower = 10;

class _DetailsScreenState extends State<DetailsScreen> {
  List<ParkingSlot> parkingSlots = [
    ParkingSlot(location: 1, isOccupied: false, isSelected: false),
    ParkingSlot(location: 2, isOccupied: true, isSelected: false),
    ParkingSlot(location: 3, isOccupied: true, isSelected: false),
    ParkingSlot(location: 4, isOccupied: false, isSelected: false)
  ];
  List<ParkingSlot> bookedSlots = [
    ParkingSlot(location: 1, isOccupied: true, isSelected: false),
    ParkingSlot(location: 2, isOccupied: false, isSelected: false),
  ];
  bool isLoaded = true;
  Future<void> getData() async {
    // await Firestore.instance
    // .collection("towersInfo")
    // .document("mainInfo")
    // .get()
    // .then((value) {
    //   totalSize = value['occupancy'];
    //   numberOfTowers = value['numberOfTowers'];
    //   numberOfParkingSlotsInEachTower = value['numberOfParkingSlots'];
    // });

    // Firestore.instance
    //     .collection("towersInfo")
    //     .document("tower" + widget.location)
    //     .snapshots()
    //     .listen((value) {
    var value;
    var user;

    // setState(() {
    //   parkingSlots.clear();
    //   bookedSlots.clear();
    // });
    bool isOccupied;
    for (int i = 1; i <= numberOfParkingSlotsInEachTower; i++) {
      isOccupied = value.data['parkingSlot$i']['isOccupied'];
      if (isOccupied) {
        String userIDBookedByTheUser;
        userIDBookedByTheUser = value.data['parkingSlot$i']['ownerID'];
        if (userIDBookedByTheUser == user.uid) {
          setState(() {
            bookedSlots.add(
                ParkingSlot(location: 1, isOccupied: true, isSelected: true));
          });
        } else {
          setState(() {
            parkingSlots.add(
                ParkingSlot(location: 1, isOccupied: true, isSelected: true));
          });
        }
      } else {
        setState(() {
          parkingSlots.add(
              ParkingSlot(location: 1, isOccupied: true, isSelected: true));
        });
      }
    }
    setState(() {
      isLoaded = !isLoaded;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  final TextEditingController _passwordController =
      TextEditingController(text: "");

  Future<void> bookParkingSlots() async {
    print(availableLocationsSelected);
    if (availableLocationsSelected.isNotEmpty) {
      _showDialog(true);
    } else {
      print("Select Atleast One");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Select Atleast One",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _showDialog(bool isBooked) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

                  if (pass == (_passwordController.text + "@1234!")) {
                    print("PAssword Matched");
                    if (isBooked) {
                      book();
                    } else {
                      unbook();
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
      ),
    );
  }

  Future<void> unbookParkingSlots() async {
    print("bookedLocationsSelected");
    if (bookedLocationsSelected.isNotEmpty) {
      _showDialog(false);
    } else {
      print("Select Atleast One");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Select Atleast One",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

  void unbook() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Please wait we are unbooking...",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.green,
      duration: Duration(minutes: 5),
    ));
    int occupancy;
    int availableSlots;
    // Firestore db = Firestore.instance;
    // await db
    //     .collection("towersInfo")
    //     .document("mainInfo")
    //     .get()
    //     .then((onValue) {
    //   occupancy = onValue.data['occupancy'];
    //   availableSlots = onValue.data['availableSlots'];
    // });
    // await db.collection("towersInfo").document("mainInfo").updateData({
    //   'occupancy': occupancy - bookedLocationsSelected.length,
    //   'availableSlots': availableSlots + bookedLocationsSelected.length
    // });
    dynamic db;
    for (int i = 1; i <= bookedLocationsSelected.length; i++) {
      await db
          .collection("towersInfo")
          .document("tower${widget.location}")
          .updateData({
        'parkingSlot${bookedLocationsSelected.toList()[i - 1]}': {
          'isOccupied': false,
          'ownerID': "",
          'occupiedTimeStamp': null,
        }
      });
    }
    int availableParkingSlots = 0;
    int occupiedParkingSlots = 1;
    await db.collection("towersInfo").document("towers").get().then((value) {
      availableParkingSlots =
          value.data['tower${widget.location}']['availableSlots'];
      occupiedParkingSlots = value.data['tower${widget.location}']['occupied'];
    });
    await db.collection("towersInfo").document("towers").updateData({
      'tower${widget.location}': {
        'availableSlots':
            availableParkingSlots + bookedLocationsSelected.length,
        'occupied': occupiedParkingSlots - bookedLocationsSelected.length,
      }
    });
    print("Data Updated Successfuly");
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "UnBooked  Successfully",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
    bookedLocationsSelected.clear();
  }

  void book() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Please wait we are booking...",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.green,
      duration: Duration(minutes: 5),
    ));
    int occupancy;
    int availableSlots;
    // FirebaseAuth auth = FirebaseAuth.instance;
    var db;
    dynamic user;
    await db
        .collection("towersInfo")
        .document("mainInfo")
        .get()
        .then((onValue) {
      occupancy = onValue.data['occupancy'];
      availableSlots = onValue.data['availableSlots'];
    });
    // await db.collection("towersInfo").document("mainInfo").updateData({
    //   'occupancy': occupancy + availableLocationsSelected.length,
    //   'availableSlots': availableSlots - availableLocationsSelected.length,
    // });

    for (int i = 1; i <= availableLocationsSelected.length; i++) {
      await db
          .collection("towersInfo")
          .document('tower${widget.location}')
          .updateData({
        'parkingSlot${availableLocationsSelected.toList()[i - 1]}': {
          'isOccupied': true,
          'ownerID': user.uid,
          'occupiedTimeStamp': DateTime.now().millisecondsSinceEpoch,
        }
      });
    }
    int availableParkingSlots = 0;
    int occupiedParkingSlots = 1;
    await db.collection("towersInfo").document("towers").get().then((value) {
      availableParkingSlots =
          value.data['tower${widget.location}']['availableSlots'];
      occupiedParkingSlots = value.data['tower${widget.location}']['occupied'];
    });
    await db.collection("towersInfo").document("towers").updateData({
      'tower${widget.location}': {
        'availableSlots':
            availableParkingSlots - availableLocationsSelected.length,
        'occupied': occupiedParkingSlots + availableLocationsSelected.length,
      }
    });
    print("Data Updated Successfuly");
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Booked  Successfully",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
    availableLocationsSelected.clear();
  }

  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tower " + widget.location.toString()),
        centerTitle: true,
      ),
      body:
          ListView(key: key, scrollDirection: Axis.vertical, children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(18.0),
            child: parkingSlots.isNotEmpty
                ? OrientationBuilder(
                    builder: (context, orientation) => GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: parkingSlots.length,
                      itemBuilder: (itemBuilder, index) => parkingSlots.isEmpty
                          ? const CircularProgressIndicator()
                          : GridItemForAvaialbleSlots(parkingSlots[index]),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              orientation == Orientation.portrait ? 3 : 5,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20),
                    ),
                  )
                : bookedSlots.isNotEmpty
                    ? null
                    : const Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ))),
        Container(
          child: parkingSlots.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text(
                          "Occupied  ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          color: Color.fromARGB(255, 218, 35, 22),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Text(
                          "Available  ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          color: Color.fromARGB(255, 28, 126, 15),
                        )
                      ],
                    ),
                  ],
                )
              : null,
        ),
        Container(
          child: parkingSlots.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ElevatedButton(
                    onPressed: () {
                      bookParkingSlots();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Text(
                        "Book Selected Parking Slots",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: bookedSlots.isNotEmpty
              ? Container(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "Your Booked Parking Slots",
                        style: TextStyle(
                          color: Color.fromARGB(255, 4, 99, 59),
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      OrientationBuilder(
                        builder: (context, orientation) {
                          return GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: bookedSlots.length,
                            itemBuilder: (context, index) {
                              return GridItemForBookedSlots(
                                  bookedSlot: bookedSlots[index]);
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        orientation == Orientation.portrait
                                            ? 3
                                            : 5,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: ElevatedButton(
                          onPressed: () {
                            unbookParkingSlots();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10),
                            child: Text(
                              "UnBook Selected Parking Slots",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                      )
                    ],
                  ),
                )
              : null,
        ),
      ]),
    );
  }
}

class GridItemForAvaialbleSlots extends StatefulWidget {
  final ParkingSlot parkingSlot;
  GridItemForAvaialbleSlots(this.parkingSlot);
  @override
  _GridItemForAvaialbleSlotsState createState() =>
      _GridItemForAvaialbleSlotsState();
}

Set<int> availableLocationsSelected = {};
Set<int> bookedLocationsSelected = {};

class _GridItemForAvaialbleSlotsState extends State<GridItemForAvaialbleSlots> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!widget.parkingSlot.isOccupied) {
            widget.parkingSlot.isSelected = !widget.parkingSlot.isSelected;
            if (widget.parkingSlot.isSelected) {
              availableLocationsSelected.add(widget.parkingSlot.location);
            } else {
              availableLocationsSelected.remove(widget.parkingSlot.location);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Already Occupied",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ));
          }
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: widget.parkingSlot.isOccupied ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(20),
            border: widget.parkingSlot.isSelected
                ? const BorderDirectional(
                    start: BorderSide(color: Colors.green, width: 5),
                    top: BorderSide(color: Colors.green, width: 5),
                    bottom: BorderSide(color: Colors.green, width: 5),
                    end: BorderSide(color: Colors.green, width: 5))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                widget.parkingSlot.location.toString(),
                style: const TextStyle(fontSize: 25),
              )),
            ],
          )),
    );
  }
}

class GridItemForBookedSlots extends StatefulWidget {
  final ParkingSlot bookedSlot;
  const GridItemForBookedSlots({Key? key, required this.bookedSlot})
      : super(key: key);
  @override
  _GridItemForBookedSlotsState createState() => _GridItemForBookedSlotsState();
}

class _GridItemForBookedSlotsState extends State<GridItemForBookedSlots> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(widget.bookedSlot.location);
        setState(() {
          widget.bookedSlot.isSelected = !widget.bookedSlot.isSelected;
          if (widget.bookedSlot.isSelected) {
            bookedLocationsSelected.add(widget.bookedSlot.location);
          } else {
            bookedLocationsSelected.remove(widget.bookedSlot.location);
          }
        });
        print(bookedLocationsSelected);
      },
      child: Container(
          decoration: BoxDecoration(
            color: widget.bookedSlot.isOccupied ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(20),
            border: widget.bookedSlot.isSelected
                ? const BorderDirectional(
                    start: BorderSide(color: Colors.green, width: 5),
                    top: BorderSide(color: Colors.green, width: 5),
                    bottom: BorderSide(color: Colors.green, width: 5),
                    end: BorderSide(color: Colors.green, width: 5))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                widget.bookedSlot.location.toString(),
                style: TextStyle(fontSize: 25),
              )),
            ],
          )),
    );
  }
}
