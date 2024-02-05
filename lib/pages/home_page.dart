import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:template/repo/repository.dart';
import 'package:template/models/models.dart';
import 'package:template/routes.dart';
import 'package:template/widgets/item.dart';
import 'package:template/widgets/nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  AppBar buildAppBar(BuildContext context, {required String title}) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(title),
      automaticallyImplyLeading: false,
    );
  }

  Widget buildActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.pushNamed(Routes.create.name),
      tooltip: "Create",
      child: const Icon(Icons.add),
    );
  }

  Future<bool> openDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Some title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Other'),
          ),
        ],
      ),
    );
  }

  Widget buildItem(Model item) {
    return Item(
      item: item,
      itemBuilder: (context, child) {
        return GestureDetector(
          // onTap: () => openDeleteDialog(context), TODO
          onTap: () => context.pushNamed(Routes.detail.name, pathParameters: {"id": item.id.toString()}),
          child: child,
        );
      },
    );
  }

  Widget buildBody(BuildContext context) {
    return Scrollbar(
      child: Consumer<Repository>(
        builder: (context, repo, child) {
          if (repo.isLoading) {
            return const LinearProgressIndicator();
          }

          if (!repo.isConnected && repo.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Device is not connected to Internet!"),
                  FilledButton(
                    onPressed: () => repo.reconnectToServer(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ListView.builder(
              itemCount: repo.data.length,
              itemBuilder: (context, index) {
                var item = repo.data[index];
                return buildItem(item);
              },
            )
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Exam App"),
      body: buildBody(context),
      floatingActionButton: buildActionButton(context),
      bottomNavigationBar: NavBar(currentIndex: Routes.home.index),
    );
  }
}
