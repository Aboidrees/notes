import 'package:flutter/material.dart';

myInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(
      color: Colors.grey,
      style: BorderStyle.solid,
      width: 3,
    ),
  );
}
