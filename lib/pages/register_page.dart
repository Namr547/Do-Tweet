// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  //sign user up
  void signUp() async {
    //show leading circle
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    //make sure password match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      //pop leading cirle
      Navigator.pop(context);
      //show error user
      displayMessage('Password dont match');
      return;
    }

    //try creating the user
    try {
      //create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //after  creating the user, create a new document in firestore called Users
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email!)
          .set({
        'username': emailTextController.text.split('@')[0], //initial name
        'bio': 'Empty bio...' //initially empty bio
      });
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }
  }

  //display a dialog message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.lock,
                  size: 100,
                ),
                SizedBox(
                  height: 30,
                ),

                //welcome back message
                Text(
                  'Lets create an account for you',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(
                  height: 25,
                ),

                //email textfield
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obsecureText: false),
                SizedBox(
                  height: 10,
                ),

                //password text field
                MyTextField(
                    controller: passwordTextController,
                    hintText: 'Password',
                    obsecureText: true),
                SizedBox(
                  height: 10,
                ),

                //confirm password textfield
                MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: 'Confim password',
                    obsecureText: true),

                SizedBox(
                  height: 25,
                ),

                //sign up button
                MyButton(onTap: signUp, text: 'Register'),
                SizedBox(
                  height: 25,
                ),

                //go to login page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      //to display login or register page, we used this ontap
                      onTap: widget.onTap,
                      child: Text(
                        'Login here',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
