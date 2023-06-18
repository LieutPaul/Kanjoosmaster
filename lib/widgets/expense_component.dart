import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "${widget.title}\n${widget.date}",
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.w800, color: Colors.black),
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
                    fontSize: 17.5, fontWeight: FontWeight.w600),
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
            ]),
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
      ),
    );
  }
}
