import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  AppTextField(
      {@required this.controller,
      @required this.onChanged,
      this.label,
      this.autofocus: false,
      this.hiddenField: false,
      this.inputType: TextInputType.text,
      this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final String label;
  final TextInputType inputType;
  final bool autofocus;
  final bool hiddenField;

  @override
  _AppTextFieldState createState() => _AppTextFieldState(
      onChanged, onSubmitted, controller, label, autofocus, hiddenField, inputType);
}

class _AppTextFieldState extends State<AppTextField> {
  _AppTextFieldState(this.onChanged, this.onSubmitted, this.controller, this.label,
      this.autofocus, this.hiddenField, this.inputType);

  TextEditingController controller;
  ValueChanged<String> onChanged;
  ValueChanged<String> onSubmitted;
  String label;
  TextInputType inputType;
  bool autofocus;
  bool hiddenField;

  @override
  Widget build(BuildContext context) {
    if (onSubmitted == null) onSubmitted = onChanged;
    return TextField(
      cursorWidth: 2.0,
      keyboardType: inputType,
      autofocus: autofocus,
      textCapitalization: inputType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      style: Theme.of(context).textTheme.body1,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(color: Theme.of(context).accentColor)),
          contentPadding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
          labelText: label),
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: hiddenField,
    );
  }
}
