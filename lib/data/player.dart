import 'package:flutter/material.dart';
class Player {
  Player({ this.name, this.color, this.docId });

  String name;
  Color color;
  String docId = '';

  bool operator ==(o) => o is Player &&
                  // o.name == name && 
                  // o.color.value == color.value && 
                  o.docId == docId;

  int get hashCode => 31 * /* name.hashCode + color.hashCode * 17 +*/ docId.hashCode * 3;
}