import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late Razorpay razorpay;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_cfJ7xYbqBG65Gz",
      "amount": num.parse(textEditingController.text) * 100,
      "name": "Choose Payment Method",
      "description": "Payment For the More Coins you Need",
      "prefill": {"contact": "enter your phone", "email": "Email@gmail.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess() {
    print("Pament success");
    Toast.show("Pament success");
  }

  void handlerErrorFailure() {
    print("Pament error");
    Toast.show("Pament error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Toast.show("External Wallet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Get More Coins"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(children: [
              Text(" 150 EGP For :   100 ",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
              Icon(
                Icons.monetization_on_outlined,
                color: Color.fromARGB(255, 255, 217, 0),
                size: 40,
                semanticLabel: "0.0",
              ),
            ]),
            Row(children: [
              Text(" 200 EGP For :   150 ",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
              Icon(
                Icons.monetization_on_outlined,
                color: Color.fromARGB(255, 255, 217, 0),
                size: 40,
                semanticLabel: "0.0",
              ),
            ]),
            Row(children: [
              Text(" 250 EGP For :   200 ",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
              Icon(
                Icons.monetization_on_outlined,
                color: Color.fromARGB(255, 255, 217, 0),
                size: 40,
                semanticLabel: "0.0",
              ),
            ]),
            Row(children: [
              Text(" 300 EGP For :   300 ",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
              Icon(
                Icons.monetization_on_outlined,
                color: Color.fromARGB(255, 255, 217, 0),
                size: 40,
                semanticLabel: "0.0",
              ),
            ]),
            Text("  "),
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: "amount to pay"),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              //  style:ButtonStyle(backgroundColor:),
              child: Text(
                "Pay Now",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              onPressed: () {
                openCheckout();
              },
            )
          ],
        ),
      ),
    );
  }
}
