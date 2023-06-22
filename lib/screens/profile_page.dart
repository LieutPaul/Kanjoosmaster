import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kanjoosmaster/widgets/my_text_button.dart';
import '../components/get_categories.dart';
import '../components/get_large_expenses.dart';
import '../components/get_username.dart';

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
      body: body(),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        topBar(),
        Expanded(
          child: ListView(
            children: [
              const Icon(Icons.person, size: 162, color: Colors.white),
              getUserName(context),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                    width: 110,
                    height: 40,
                    child: MyTextButton(
                      bgColor: Colors.blue,
                      buttonName: "Sign Out",
                      onTap: () => _signOut(),
                      textColor: Colors.white,
                    )),
              ),
              const SizedBox(height: 15),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Expense Categories",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 115, 177, 117),
                        fontSize: 25)),
              ),
              getCategories(context),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Large Purchases You want to Make",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 115, 177, 117),
                        fontSize: 25)),
              ),
              getLargeExpenses(context),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Recurring Expenditures",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 115, 177, 117),
                        fontSize: 25)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Container topBar() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              "Profile Details",
              style: TextStyle(fontSize: 25, color: Colors.white),
            )),
          ),
        ),
      ),
    );
  }
}
