import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Row getUserName(BuildContext context) {
  var currentUser = FirebaseAuth.instance.currentUser;
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

              return Text("${currentUser.email}");
            }
          }),
      const Icon(Icons.edit, color: Colors.white)
    ],
  );
}
