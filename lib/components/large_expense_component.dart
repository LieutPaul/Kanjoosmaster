import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class LargeExpense extends StatefulWidget {
  final List<dynamic> links;
  final String id;
  final String title;
  final int amount;
  final int savedAmount;
  const LargeExpense(
      {super.key,
      required this.title,
      required this.amount,
      required this.links,
      required this.id,
      required this.savedAmount});

  @override
  State<LargeExpense> createState() => _LargeExpenseState();
}

class _LargeExpenseState extends State<LargeExpense> {
  var currentUser = FirebaseAuth.instance.currentUser;
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        leading: isExpanded == false
            ? const Icon(Icons.arrow_forward_ios)
            : const Icon(Icons.expand_more, size: 40),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 19, color: Colors.black),
        ),
        trailing: Text("${widget.amount}",
            style: const TextStyle(fontSize: 17.5, color: Colors.black)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 30),
              child: Text(
                "You have saved: ${widget.savedAmount}",
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 30),
              child: Text(
                "Links: (Long Press to Copy a Link)",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                  children: widget.links.asMap().entries.map((entry) {
                return GestureDetector(
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(text: entry.value));
                    },
                    onTap: () {
                      launchUrl(Uri.parse(entry.value));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        "Link ${entry.key + 1}",
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ));
              }).toList()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 91, 123, 255)),
                icon: const Icon(
                  Icons.add,
                  size: 22,
                  color: Colors.white,
                ),
                label: const Text(
                  "Add Money",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _addMoney,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 91, 123, 255)),
                icon: const Icon(
                  Icons.link,
                  size: 22,
                  color: Colors.white,
                ),
                label: const Text(
                  "Add Link",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _addLink,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Future<void> _addMoney() async {
    int savedValue = 0;
    bool canAdd = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Save Money",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "New Saved Amount",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            savedValue = parsedValue;
                          }
                        },
                      ),
                    ],
                  ))),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {
                      if (savedValue > 0) {
                        Navigator.of(context).pop(savedValue);
                        canAdd = true;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Enter Valid Inputs",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 20.0);
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ));
    if (canAdd) {
      var documentRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email);

      var documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        var largeExpenses =
            documentSnapshot.data()!['LargeExpenses'] as List<dynamic>;
        for (var i = 0; i < largeExpenses.length; i++) {
          var expense = largeExpenses[i];
          if (expense['Id'] == widget.id) {
            largeExpenses[i]['SavedAmount'] = savedValue;
            await documentRef.update({
              'LargeExpenses': largeExpenses,
            });
            break;
          }
        }
      }
    }
  }

  Future<void> _addLink() async {
    String newLink = "";
    bool canAdd = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Add a New Link to the product",
                  style: TextStyle(color: Colors.black)),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "New Link",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) {
                          newLink = value;
                        },
                      ),
                    ],
                  ))),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {
                      if (newLink != "") {
                        Navigator.of(context).pop(newLink);
                        canAdd = true;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Enter Valid Inputs",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 20.0);
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ));
    if (canAdd) {
      var documentRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email);

      var documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        var largeExpenses =
            documentSnapshot.data()!['LargeExpenses'] as List<dynamic>;
        for (var i = 0; i < largeExpenses.length; i++) {
          var expense = largeExpenses[i];
          if (expense['Id'] == widget.id) {
            if (largeExpenses[i]["Links"].contains(newLink) == false) {
              largeExpenses[i]['Links'].add(newLink);
            }
            await documentRef.update({
              'LargeExpenses': largeExpenses,
            });
            break;
          }
        }
      }
    }
  }
}
