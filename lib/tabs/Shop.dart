import 'package:flutter/material.dart';

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ShopState();
}

/// The state for DetailsScreen
class ShopState extends State<Shop> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Shop'),
      ),
    );
  }
}