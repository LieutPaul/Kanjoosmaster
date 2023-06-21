import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var currentUser = FirebaseAuth.instance.currentUser;
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.80),
      body: SafeArea(child: body()),
    );
  }

  Widget body() {
    return ListView(
      children: [
        const Icon(Icons.person, size: 162, color: Colors.white),
        getUserName(),
        const SizedBox(height: 10),
        const Divider(
          color: Colors.white,
          thickness: 1,
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text("Expense Categories",
              style: TextStyle(
                  color: Color.fromARGB(255, 115, 177, 117), fontSize: 20)),
        ),
        getExpenses(),
      ],
    );
  }

  Row getUserName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.hasData) {
                  return Text(
                    "${(snapshot.data!.data())?["Name"]} ",
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error ${snapshot.error}");
                }

                return Text("${currentUser!.email}");
              }
            }),
        const Icon(Icons.edit, color: Colors.white)
      ],
    );
  }

  Column getExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.hasData) {
                  var point = 1;
                  List<dynamic> c = snapshot.data!.data()?["ExpenseCategories"];
                  List<Widget> w = [const SizedBox(height: 5)];
                  for (var category in c) {
                    w.add(Text(
                      "$point. $category",
                      style: const TextStyle(color: Colors.white),
                    ));
                    w.add(const SizedBox(height: 10));
                    point++;
                  }
                  w.add(const SizedBox(height: 15));
                  w.add(
                    Center(
                        child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 10.0),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Add Expense",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )),
                  );
                  return Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: w,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error ${snapshot.error}");
                }
                return const CircularProgressIndicator();
              }
            }),
      ],
    );
  }
}
