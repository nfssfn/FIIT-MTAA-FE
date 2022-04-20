import 'package:flutter/material.dart';

SnackBar getSnackBar(String text) {
  return SnackBar(content: Text(text));
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(text));
}