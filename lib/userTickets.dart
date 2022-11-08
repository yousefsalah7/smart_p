import 'dart:ui';

import 'package:flutter/material.dart';

class Ticket extends StatefulWidget {
  const Ticket({Key? key}) : super(key: key);

  @override
  State<Ticket> createState() => _TicketState();
}

class Movie {
  String? name;
  String? price;

  Movie({this.name, this.price});

  void addTiket(time, ticketnum) {
    cinemas.add(Movie(name: ticketnum, price: time));
  }
}

List cinemas = [
  Movie(name: "TicKet_Number", price: "Booking_Time"),
];

class _TicketState extends State<Ticket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 211, 255, 198),
        body: ListView.builder(
            itemCount: cinemas.length,
            itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Text(
                      "${cinemas[index].name}",
                      style: TextStyle(color: Colors.pink, fontSize: 25),
                    ),
                    trailing: Text(
                      "${cinemas[index].price}",
                      style: TextStyle(color: Colors.pink, fontSize: 25),
                    ),
                  ),
                )));
  }
}
