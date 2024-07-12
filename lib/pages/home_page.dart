// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_tweet/components/drawer.dart';
import 'package:do_tweet/components/text_field.dart';
import 'package:do_tweet/components/tweet_post.dart';
import 'package:do_tweet/helper/helper_methods.dart';
import 'package:do_tweet/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //sign user out
  void SignOut() {
    FirebaseAuth.instance.signOut();
  }

  //post message
  void postMessage() {
    //only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      //store in the firebase
      FirebaseFirestore.instance.collection('User Posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    //clear the text field
    setState(() {
      textController.clear();
    });
  }

  //navigate to profile page
  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Do Tweet'),
        actions: [
          //sign out button
          IconButton(onPressed: SignOut, icon: Icon(Icons.logout))
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOutTap: SignOut,
      ),
      body: Center(
        child: Column(
          children: [
            //the tweet
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .orderBy(
                          'TimeStamp',
                          descending: false,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              //get the message
                              final post = snapshot.data!.docs[index];
                              // Fetch comments for this tweet and calculate comment count
                              // final comments =
                              //     List<String>.from(post['Comments'] ?? []);
                              // final commentCount = comments.length;
                              return Tweet(
                                message: post['Message'],
                                user: post['UserEmail'],
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                time: formatDate(post['TimeStamp']),
                                // comments:
                                // List<String>.from(post['Comments'] ?? []),
                                // commentCount: commentCount,
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error:${snapshot.error}'),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    })),

            //post message
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextField(
                          controller: textController,
                          hintText: 'Write a tweet here...',
                          obsecureText: false)),

                  //post button
                  IconButton(
                      onPressed: postMessage, icon: Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            //logged in as
            Text(
              "Logged in as:${currentUser.email!}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
