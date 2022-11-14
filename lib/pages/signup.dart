import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/pages/home.dart';
import 'package:crud/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Signup extends StatelessWidget {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 100,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  hintText: 'Fullname',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: address,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: user,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                controller: pass,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(130, 50),
                      backgroundColor: Colors.green),
                  onPressed: () async {
                    final fullname = name.text.trim();
                    final add = address.text.trim();
                    final username = user.text.trim();
                    final password = pass.text.trim();
                    bool hasInternet =
                        await InternetConnectionChecker().hasConnection;

                    if (fullname.isEmpty ||
                        add.isEmpty ||
                        username.isEmpty ||
                        password.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Incomplete Fields',
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
                    } else if (hasInternet == true) {
                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: '$username@samplecrud.com',
                                password: password)
                            .then((value) async {
                          User? user = FirebaseAuth.instance.currentUser;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .set({
                            'uid': user?.uid,
                            'fullname': fullname,
                            'username': username,
                            'password': password,
                            'address': add,
                          });
                        });
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Account Successfully Created!',
                                    style: TextStyle(color: Colors.green)),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      'OK',
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage()));
                                    },
                                  )
                                ],
                              );
                            });
                      } on FirebaseAuthException catch (e) {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Error',
                                    style: TextStyle(color: Colors.red)),
                                content: Text(
                                  '${e.message}',
                                ),
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
                                  child: const Text('CLOSE'),
                                )
                              ],
                            );
                          });
                    }
                  },
                  child: const Text('Register',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(130, 50),
                      backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: const Text('Cancel',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
            ]),
          ),
        ),
      ),
    );
  }
}
