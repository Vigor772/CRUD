import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class Updates extends StatefulWidget {
  @override
  _UpdatesState createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> {
  late String noteid = '';
  String useruid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController title = TextEditingController();
  TextEditingController contents = TextEditingController();
  late Stream<QuerySnapshot> updates;

  Future addNote(title, content) async {
    await FirebaseFirestore.instance.collection('notes').add({
      'user_id': useruid,
      'title': title,
      'content': content,
      'date_created': Timestamp.now(),
    }).then((value) async {
      setState(() {
        noteid = value.id;
      });
    });
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(noteid)
        .set({'note_id': noteid}, SetOptions(merge: true));
  }

  Future deleteNote(noteid) async {
    await FirebaseFirestore.instance.collection('notes').doc(noteid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
          height: 75,
          width: MediaQuery.of(context).size.width * 1,
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(offset: Offset.zero, blurRadius: 3, spreadRadius: -1)
          ], color: Colors.pinkAccent),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Add New Note",
                              style: TextStyle(color: Colors.red)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                  decoration:
                                      const InputDecoration(hintText: 'Title'),
                                  controller: title),
                              TextFormField(
                                  decoration: const InputDecoration(
                                      hintText: 'Content'),
                                  controller: contents),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () async {
                                  final notetitle = title.text.trim();
                                  final notecontents = contents.text.trim();
                                  bool hasInternet =
                                      await InternetConnectionChecker()
                                          .hasConnection;
                                  if (hasInternet == true) {
                                    if (notetitle.isEmpty ||
                                        notecontents.isEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Incomplete Fields",
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
                                      addNote(notetitle, notecontents);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Note Added",
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
                                      setState(() {
                                        title.text = ' ';
                                        contents.text = ' ';
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
                                child: const Text('Confirm')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close')),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.add),
                iconSize: 25,
              ),
              const Text('Add Note', style: TextStyle(fontSize: 25)),
            ],
          ),
        ),
        StreamBuilder(
            stream: updates = FirebaseFirestore.instance
                .collection('notes')
                .where('user_id', isEqualTo: useruid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Container(child: const Center(child: Text('No Data')));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('waiting');
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  )),
                );
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: snapshot.data!.docs
                      .map((updates) => Container(
                            padding: EdgeInsets.all(15),
                            alignment: Alignment.topLeft,
                            height: 120,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  Column(children: [
                                    (updates['title'] != null)
                                        ? Text("Title: ${updates['title']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25))
                                        : const Text("Title: Loading...",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25)),
                                    const SizedBox(height: 15),
                                    (updates['content'] != null)
                                        ? Text(updates['content'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18))
                                        : const Text('Loading... ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                    const SizedBox(height: 10),
                                    (updates['date_created'] != null)
                                        ? Text(
                                            "Created:${DateFormat('yyyy-MM-dd – kk:mm').format(updates['date_created'].toDate())}")
                                        : const Text("Created: Loading...")
                                  ]),
                                  Expanded(
                                    child: IconButton(
                                        onPressed: () {
                                          deleteNote(noteid);
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 40)),
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList());
            }),
      ],
    );
  }
}
