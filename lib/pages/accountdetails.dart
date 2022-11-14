import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/pages/home.dart';
import 'package:crud/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  late String name = ' ';
  late String username = ' ';
  late String address = ' ';
  String userid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController newadd = TextEditingController();

  getCurrentUserData() async {
    String useruid = FirebaseAuth.instance.currentUser!.uid;
    var userdata = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: useruid)
        .get();
    if (mounted) {
      setState(() {
        for (var snapshots in userdata.docs) {
          Map<String, dynamic> data = snapshots.data();
          name = data['fullname'] ?? 'Loading... ';
          username = data['username'] ?? 'Loading... ';
          address = data['address'] ?? 'Loading...  ';
        }
      });
    }
  }

  Future updateUserAddress(changedAdd) async {
    await FirebaseFirestore.instance.collection('users').doc(userid).set({
      'address': changedAdd,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    getCurrentUserData();
    super.initState();
  }

  @override
  void dispose() {
    newadd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            height: 75,
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(offset: Offset.zero, blurRadius: 3, spreadRadius: -1)
            ], color: Colors.pinkAccent),
            child: const Text('Account Details',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
                child: Column(
              children: [
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Name', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 15),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Username', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 15),
                    Text(username,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Address', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 15),
                    Text(address,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Enter New Address'),
                            content: TextFormField(controller: newadd),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  final newaddress = newadd.text.trim();
                                  bool hasInternet =
                                      await InternetConnectionChecker()
                                          .hasConnection;
                                  if (hasInternet == true) {
                                    if (newaddress.isEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Address is blank",
                                                  style: TextStyle(
                                                      color: Colors.red)),
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
                                    } else {
                                      updateUserAddress(newaddress);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Address Updated Successfully",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          HomePage()));
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
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                                child: const Text('Confirm'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 50),
                      backgroundColor: const Color(0xffD6E4E5)),
                  child: const Text('Update Address'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()));
                      FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(170, 50),
                        backgroundColor: Colors.red),
                    child: const Text('Log Out'))
              ],
            )),
          )
        ],
      ),
    );
  }
}
