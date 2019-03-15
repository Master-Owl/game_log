import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  Player({ this.name, this.color, this.dbRef }) {
    if (name == null) name = '';
    if (color == null) color = Colors.black;
  }

  String name;
  Color color;  
  DocumentReference dbRef;

  bool operator ==(o) => o is Player &&
                  // o.name == name && 
                  // o.color.value == color.value && 
                  o.dbRef == dbRef;

  int get hashCode => 31 * /* name.hashCode + color.hashCode * 17 +*/ dbRef.hashCode * 3;
}