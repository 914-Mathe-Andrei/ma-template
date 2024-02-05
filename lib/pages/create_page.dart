import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:template/config.dart';
import 'package:template/exceptions.dart';
import 'package:template/repo/repository.dart';
import 'package:template/utils.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<StatefulWidget> createState() => _CreatePage();
}

class _CreatePage extends State<CreatePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController dateController = TextEditingController(text: DateFormat(DATETIME_FORMAT).format(DateTime.now()));
  final TextEditingController numberController = TextEditingController(text: "0");

  Future<bool> createItem() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // TODO
    String name = nameController.text;
    String date = dateController.text;
    int number = int.parse(numberController.text);

    try {
      final repo = Provider.of<Repository>(context, listen: false);
      await repo.create(name);
    } on ExamAppException catch (e) {
      Fluttertoast.showToast(msg: e.message, toastLength: Toast.LENGTH_LONG);
    }

    return true;
  }

  AppBar buildAppBar(BuildContext context, {required String title}) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(title),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.close),
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    if (repo.isLoading) {
      return const SizedBox();
    }

    return BottomAppBar(
      child: FilledButton(
        onPressed: () {
          createItem().then((value) {
            if (value) {
              context.pop();
            }
          });
        },
        child: const Text("Create"),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<Repository>(
      builder: (context, repo, child) {
        if (repo.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: () async {
                    var dateTime = await openDateTimePicker(context);
                    if (dateTime != null) {
                      dateController.text =
                          DateFormat(DATETIME_FORMAT).format(dateTime);
                    }
                  },
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Number",
                    suffixIcon: Icon(Icons.numbers),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty!";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Create item"),
      body: buildBody(context),
      bottomNavigationBar: buildBottomBar(context),
    );
  }
}