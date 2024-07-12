// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'package:do_tweet/components/button.dart';
import 'package:do_tweet/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //sign user in
  void signIn() async {
    //show  leading circle
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);

      //pop leading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop leading circle
      Navigator.pop(context);
      //display error message
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
                  'Wellcome back you have been missed!',
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
                  height: 25,
                ),

                //sign in button
                MyButton(
                    onTap: () {
                      signIn();
                    },
                    text: 'Sign In'),
                SizedBox(
                  height: 25,
                ),

                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      //to display login or register page, we used this ontap

                      onTap: widget.onTap,
                      child: Text(
                        'Register now',
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
