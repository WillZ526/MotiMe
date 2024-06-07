import 'package:flutter/material.dart';

class Themes {
  static Widget titleSmall(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }

  static Widget titleMedium(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  static Widget titleLarge(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  static Widget bodySmall(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  static Widget bodyMedium(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  static Widget bodyLarge(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  static Widget headlineSmall(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  static Widget headlineMedium(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  static Widget headlineLarge(String text, context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }
}
