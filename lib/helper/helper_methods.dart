//return a formated data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  //timestamp is the object we retrive from firebase
  //so to display it, lets convert it to a string
  DateTime dateTime = timestamp.toDate();

  //get year
  String year = dateTime.year.toString();

  //get month
  String month = dateTime.month.toString();

  //get day
  String day = dateTime.day.toString();

  //final formatted date

  String formattedDate = '$day/$month/$year';

  return formattedDate;
}
