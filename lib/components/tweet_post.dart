// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_tweet/components/comment.dart';
import 'package:do_tweet/components/comment_button.dart';
import 'package:do_tweet/components/delete_button.dart';
import 'package:do_tweet/components/like_button.dart';
import 'package:do_tweet/helper/helper_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Tweet extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  // final List<String> comments;

  const Tweet({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    // required this.comments
  });

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  //get the user from firebase
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool areCommentsVisible = false;

  final commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle likes
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //access the document in firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      //if the post is now liked, add the users email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      //if the post is now unliked, remove the users email from the 'unlike' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

//add comment
  void addComment(String commentText) {
    //write the comment to the firestore under the comment collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection('Comments')
        .add({
      "CommentText": commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now()
    });
  }

//show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Add comment'),
              content: TextField(
                controller: commentTextController,
                decoration: InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () {
                      // pop box
                      Navigator.pop(context);
                      //clear controller
                      commentTextController.clear();
                    },
                    child: Text('Cancel')),

                //post button
                TextButton(
                    onPressed: () {
                      //add comment
                      addComment(commentTextController.text);

                      Navigator.pop(context);
                      //clear controller
                      commentTextController.clear();
                    },
                    child: Text('Post')),
              ],
            ));
  }

  //delete post method
  void deletePost() {
    //show a dialog box
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Delete Post'),
              content: Text('Are you sure you want to delete this post?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),

                //delete button
                TextButton(
                    onPressed: () async {
                      //delete the comment from firestore first
                      //if we only delete the post, the comments will still be stored in firestore
                      final commentDocs = await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .collection('Comments')
                          .get();
                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection('User Posts')
                            .doc(widget.postId)
                            .collection('Comments')
                            .doc(doc.id)
                            .delete();
                      }

                      //then delete the post
                      FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .delete()
                          .then((value) => print('post deleted'))
                          .catchError((error) =>
                              print('failed to delete the post: $error'));

                      //dismiss the dialog box
                      Navigator.pop(context);
                    },
                    child: Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //profile picture
          // Container(
          //   decoration: BoxDecoration(
          //       shape: BoxShape.circle, color: Colors.grey.shade400),
          //   padding: EdgeInsets.all(10),
          //   child: Icon(
          //     Icons.person,
          //     color: Colors.white,
          //   ),
          // ),

          //Tweet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //group of text and user email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //message
                    Text(
                      widget.message,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //user
                    Row(
                      children: [
                        Text(
                          widget.user,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        Text(' . ',
                            style: TextStyle(color: Colors.grey.shade500)),
                        Text(widget.time,
                            style: TextStyle(color: Colors.grey.shade500))
                      ],
                    )
                  ],
                ),
              ),
              //delete button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost)
            ],
          ),

          SizedBox(
            height: 20,
          ),

          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LIKE
              Row(
                children: [
                  //like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),

              //COMMENT
              Row(
                children: [
                  //comment button
                  CommentButton(
                    onTap: () {
                      showCommentDialog();
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //comment count
                  // Text(
                  //   '4',
                  //   // widget.comments.length.toString(),
                  //   style: TextStyle(color: Colors.grey),
                  // ),
                ],
              ),
              SizedBox(
                width: 5,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          areCommentsVisible = !areCommentsVisible;
                        });
                      },
                      icon: Icon(
                        Icons.visibility,
                        color: Colors.grey,
                      ))
                ],
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),

          //comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection('Comments')
                .orderBy('CommentTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //show the loading circle in no data yet
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return areCommentsVisible
                  ? ListView(
                      shrinkWrap: true, // for nested lists
                      physics: NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        //get the comment from firebase'
                        final commentData = doc.data() as Map<String, dynamic>;

                        //return the comment
                        return Comment(
                          text: commentData['CommentText'],
                          time: formatDate(commentData['CommentTime']),
                          user: commentData['CommentedBy'],
                        );
                      }).toList(),
                    )
                  : SizedBox();
            },
          )
        ],
      ),
    );
  }
}
