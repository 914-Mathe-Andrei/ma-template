import 'package:flutter/material.dart';
import 'package:template/models/models.dart';
import 'package:template/routes.dart';
import 'package:template/widgets/item.dart';
import 'package:template/widgets/nav_bar.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  AppBar buildAppBar(BuildContext context, {required String title}) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(title),
      automaticallyImplyLeading: false,
      actions: [
        FilledButton(
          onPressed: () {},
          child: const Text("Foo"),
        ),
        const SizedBox(width: 5.0),
      ],
    );
  }

  Widget buildItem(Model item) {
    return Item(item: item);
  }

  Widget buildBody(BuildContext context) {
    return const Center(
      child: Text("Fill with content"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Page"),
      body: buildBody(context),
      bottomNavigationBar: NavBar(currentIndex: Routes.page.index),
    );
  }
}
