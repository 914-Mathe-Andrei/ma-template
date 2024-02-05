import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/routes.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        if (index == widget.currentIndex) {
          return;
        }
        setState(() {
          context.pushNamed(Routes.values[index].name);
        });
      },
      selectedIndex: widget.currentIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.question_mark),
          label: "N/A",
        ),
      ],
    );
  }
}