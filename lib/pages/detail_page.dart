import 'package:flutter/material.dart';
import 'package:template/models/models.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.item});

  final Model item;

  AppBar buildAppBar(BuildContext context, {required String title}) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(title),
    );
  }

  // Widget buildBody(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
  //     child: ListView(
  //       children: [
  //         Text(
  //           "Name: ${item.name}",
  //           style: Theme.of(context).textTheme.bodyLarge,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildBody(BuildContext context) { // TODO
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Form(
        child: ListView(
          children: [
            TextFormField(
              initialValue: item.name,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 5.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Details"),
      body: buildBody(context),
    );
  }
}