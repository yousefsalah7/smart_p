import 'package:flutter/material.dart';
import 'package:smart_p/DetailsScreen.dart';
import './HomeScreen.dart';
import 'getData.dart';
import 'globals.dart' as global;

// var user = global.storage.read("userInfo");

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 211, 255, 198),
      body: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          height: 700,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 400 * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 76, 185, 66),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "LogIn",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 600 * 0.05),
                    TextFormField(
                      validator: (value) {
                        if (value == "") {
                          return "Please enter some text";
                        }
                        return null;
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 600 * 0.03),
                    TextFormField(
                      obscureText: false,
                      validator: (value) {
                        if (value == "") {
                          return "Please enter some text";
                        }
                        return null;
                      },
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 600 * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loginUsers, //<--
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 12, 92, 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15)),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pushPage(BuildContext context, Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _refresh() {
    setState(() {
      var user = global.storage.read("userInfo");
    });
  }

  Future<void> loginUsers() async {
    if (_formKey.currentState!.validate()) {
      //show snackbar to indicate loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Processing Data'),
        backgroundColor: Colors.green.shade300,
      ));

      //get response from ApiClient
      dynamic res = await ApiClient().login(
        emailController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      //if there is no error, get the user's accesstoken and pass it to HomeScreen
      if (res['ErrorCode'] == null) {
        _refresh();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      } else {
        //if an error occurs, show snackbar with error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${res['Message']}'),
          backgroundColor: Colors.red.shade300,
        ));
      }
    }
  }
}
