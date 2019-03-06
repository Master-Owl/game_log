import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  AppTextField({@required this.controller, this.onChanged, this.label});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  _AppTextFieldState createState() => _AppTextFieldState(onChanged, controller, label);
}

class _AppTextFieldState extends State<AppTextField> {
  _AppTextFieldState(this.onChanged, this.controller, this.label);

  TextEditingController controller;
  ValueChanged<String> onChanged;
  String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorWidth: 2.0,
      textCapitalization: TextCapitalization.words,
      style: Theme.of(context).textTheme.body1,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(color: Theme.of(context).accentColor)
          ),
          contentPadding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
          labelText: label
      ),
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onChanged,
    );
  }
}