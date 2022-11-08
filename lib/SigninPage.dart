import 'package:smart_p/HomeScreen.dart';

import './getData.dart';
import 'package:flutter/material.dart';
import './DetailsScreen.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = true;
  String _successText = "sucsess";
  bool _failure = false;
  String _failureText = "faluiar";
  String _userEmail = "";
  final key = GlobalKey<ScaffoldState>();
  @override
  // ignore: must_call_super
  void initState() {
    super.initState();
    _emailController.addListener(() {
      _emailController.text;
    });
    _passwordController.addListener(() {
      _passwordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    //var value = _emailController.text;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login / Sign up"),
      ),
      body: ListView(
        key: key,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Color.fromARGB(255, 253, 0, 0),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == "") {
                              return "Please enter some text";
                            }
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter some text";
                            }
                            if (value.length <= 6) {
                              return 'Please enter atleast 6 characters long password';
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                // heroTag: "btn1",
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.pink,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                    textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),

                                onPressed: () async {
                                  _register(context);
                                },
                                child: const Text('Sign Up'),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                // heroTag: "btn2",
                                autofocus: true,
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.pink,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                    textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),

                                onPressed: () {
                                  _signInWithEmailAndPassword(context);
                                },
                                child: const Text('Sign In'),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            _success == null
                                ? ''
                                : _successText == null
                                    ? ""
                                    : _successText,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            _failure == null
                                ? ''
                                : _failureText == null
                                    ? ""
                                    : _failureText,
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _register(BuildContext context) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Please Wait We are Registering you...",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.green,
    ));

    final logindata = GetData()
        .getRegisterData(_emailController.text, _passwordController.text);
    if (logindata != "") {
      print("Done");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailsScreen("Location")),
      );
      _failure = false;
      _failureText = "";
      _success = true;
      _userEmail = _emailController.text;
      _successText = "Successfully Logged in " + _emailController.text;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "You are registered Successfully",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ));
    } else {
      _failure = false;
      _failureText = "";
      _success = false;
      _successText =
          "An error occured maybe your email or password is wrong or account with this email is not created";
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "An error occured, maybe this account is already created",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _signInWithEmailAndPassword(context) async {
    final logindata = GetData()
        .getRegisterData(_emailController.text, _passwordController.text);
    if (logindata != null) {
      print("Done");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailsScreen("Location")),
      );
      _failure = false;
      _failureText = "";
      _success = true;
      _userEmail = _emailController.text;
      _successText = "Successfully Logged in " + _emailController.text;
    } else {
      _failure = false;
      _failureText = "";
      _success = false;
      _successText =
          "An error occured maybe your email or password is wrong or account with this email is not created";
    }
  }
}
