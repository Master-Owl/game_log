import 'package:flutter/material.dart';
class Player {
  Player({ this.name, this.color, this.dbId });

  String name;
  Color color;
  String dbId = '';

  bool operator ==(o) => o is Player &&
                  // o.name == name && 
                  // o.color.value == color.value && 
                  o.dbId == dbId;

  int get hashCode => 31 * /* name.hashCode + color.hashCode * 17 +*/ dbId.hashCode * 3;
}