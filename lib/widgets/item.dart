import 'package:flutter/material.dart';
import 'package:template/models/models.dart';

class Item extends StatelessWidget {
  const Item({super.key, required this.item, this.itemBuilder});

  final Model item;
  final Widget Function(BuildContext context, Widget child)? itemBuilder;

  Widget buildItem(BuildContext context) { // TODO
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Text(item.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemBuilder != null) {
      return itemBuilder!(context, buildItem(context));
    }
    return buildItem(context);
  }
}