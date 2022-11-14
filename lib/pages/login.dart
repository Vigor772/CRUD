import 'package:crud/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xffD6E4E5),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'SECURE NOTES',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              height: 250,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset.zero, blurRadius: 3, spreadRadius: -1)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.person),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Username'),
                      controller: user),
                  const SizedBox(height: 10),
                  TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.lock),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Password'),
                      controller: pass),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(100, 50),
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        final username = user.text.trim();
                        final password = pass.text.trim();
                        bool hasInternet =
                            await InternetConnectionChecker().hasConnection;
                        if (username.isEmpty || password.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Please complete the fields',
                                      style: TextStyle(color: Colors.red)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('CLOSE'),
                                    )
                                  ],
                                );
                              });
                        } else if (hasInternet == true) {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: '$username@samplecrud.com',
                                    password: password);
                          } on FirebaseAuthException catch (e) {
                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Error',
                                        style: TextStyle(color: Colors.red)),
                                    content: Text('${e.message}'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'CLOSE',
                                          ))
                                    ],
                                  );
                                });
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('NO INTERNET',
                                      style: TextStyle(color: Colors.red)),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'CLOSE',
                                        ))
                                  ],
                                );
                              });
                        }
                      },
                      child: const Text('Login',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Signup(),
                  ));
                },
                child: const Text("No Account Yet? Create Here.")),
          ]),
        ),
      ),
    );
  }
}
