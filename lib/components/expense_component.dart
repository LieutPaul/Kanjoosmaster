import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Expense extends StatefulWidget {
  final String expenseId;
  final String title;
  final String description;
  final String category;
  final int amount;
  final bool earning; // true -> It is earning, not income
  final String date;
  const Expense(
      {super.key,
      required this.title,
      required this.category,
      required this.amount,
      required this.earning,
      required this.expenseId,
      required this.description,
      required this.date});

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  void _launchURL(String url) async {
    // ignore: deprecated_member_use
    await launch(url);
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => expandedTransaction(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.money_sharp,
            color: widget.earning == false ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          widget.title,
          style:
              TextStyle(color: Colors.grey[200], fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          widget.category,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: Text(
          widget.amount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Future<void> expandedTransaction() async {
    PlatformFile? pickedFile;

    await showDialog(
        context: context,
        builder: (context) {
          Future uploadFile() async {
            final result = await FilePicker.platform.pickFiles();
            if (result == null) {
              return;
            }
            setState(() {
              pickedFile = result.files.first;
            });
          }

          Future addFile() async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16.0),
                        Text('Adding Receipt...'),
                      ],
                    ),
                  ),
                );
              },
            );
            final path = "receipts/${widget.expenseId}/${pickedFile!.name}";
            final file = File(pickedFile!.path!);
            final ref = FirebaseStorage.instance.ref().child(path);
            UploadTask? uploadTask = ref.putFile(file);
            await uploadTask.whenComplete(() => {});
            setState(() {
              uploadTask = null;
            });
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }

          Future<List<String>> getReceiptUrls() async {
            List<String> urls = [];

            var result = await FirebaseStorage.instance
                .ref('receipts/${widget.expenseId}')
                .listAll();

            for (var ref in result.items) {
              String downloadUrl = await ref.getDownloadURL();
              urls.add(downloadUrl);
            }

            return urls;
          }

          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "${widget.title}\n${widget.date}",
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.category,
                      style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You ${widget.earning == true ? "earned" : "spent"} ${widget.amount} on this Transaction.",
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<String>>(
                      future: getReceiptUrls(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<String>? urls = snapshot.data;

                          List<Widget> textWidgets = [];
                          for (String url in urls!) {
                            textWidgets.add(GestureDetector(
                                onTap: () => _launchURL(url),
                                child: const Text(
                                  "Open Receipt",
                                )));
                            textWidgets.add(const SizedBox(height: 10));
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Receipts: ',
                                style: TextStyle(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline),
                              ),
                              const SizedBox(height: 10),
                              Column(children: textWidgets),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (pickedFile != null)
                      Column(
                        children: [
                          Text(
                            pickedFile!.name,
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              await addFile();
                              setState(() {
                                pickedFile = null;
                              });
                            },
                            child: const Text(
                              "Confirm Addition",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ElevatedButton(
                        onPressed: () async {
                          await uploadFile();
                          setState(() {});
                        },
                        child: const Text("Add a Receipt"))
                  ]),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16.0),
                                  Text('Deleting...'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      try {
                        CollectionReference expensesCollection =
                            FirebaseFirestore.instance.collection('Expenses');

                        DocumentReference documentRef =
                            expensesCollection.doc(widget.expenseId);

                        DocumentSnapshot<Map<String, dynamic>> snapshot =
                            await documentRef.get()
                                as DocumentSnapshot<Map<String, dynamic>>;

                        if (snapshot.exists) {
                          Map<String, dynamic> data = snapshot.data()!;

                          List<dynamic> users = List.from(data['Users']);

                          users.remove(currentUser!.email);

                          await documentRef.update({'Users': users});

                          if (users.isEmpty) {
                            await documentRef.delete();
                          }
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } catch (error) {
                        // ignore: avoid_print
                        print('Error deleting document: $error');
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Delete Transaction",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            );
          }));
        });
  }
}
