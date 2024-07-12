// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_tweet/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //get current user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //all users
  final usersCollection = FirebaseFirestore.instance.collection('Users');

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: Text(
                'Edit $field',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Enter new $field',
                    hintStyle: TextStyle(color: Colors.grey)),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),

                //save button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(newValue),
                    child: Text('Save')),
              ],
            ));
    //update in firestore
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile Page'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              //get user data
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    //profile pic
                    Icon(
                      Icons.person,
                      size: 72,
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    //user email
                    Text(
                      currentUser.email!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      height: 50,
                    ),

                    //user details
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'My Details',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),

                    //username
                    MyTextBox(
                      text: userData['username'],
                      sectionName: 'username',
                      onPressed: () => editField('username'),
                    ),

                    //bio
                    MyTextBox(
                      text: userData['bio'],
                      sectionName: 'bio',
                      onPressed: () => editField('bio'),
                    )

                    //user posts
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error${snapshot.error}'),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
