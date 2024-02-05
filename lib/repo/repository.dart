import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:template/exceptions.dart';
import 'package:template/models/models.dart';
import 'package:template/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Repository extends ChangeNotifier {
  late final Realm realm;
  late WebSocketChannel socket;
  late StreamSubscription<ConnectivityResult> subscription;
  bool isConnected = false;
  bool isLoading = true;

  late RealmResults<Model> data;
  List<int> dataOutOfSync = [];

  Repository() {
    // init realm db
    final config = Configuration.local([Model.schema]);
    realm = Realm(config);

    // init data
    initData().then((_) {
      isLoading = false;
      notifyListeners();
    });

    // init connectivity subscription
    subscription = Connectivity().onConnectivityChanged.listen(handleConnection);
  }

  @override
  void dispose() {
    // close connectivity subscription
    subscription.cancel();

    // close socket
    socket.sink.close();

    // close realm
    realm.close();

    super.dispose();
  }

  Future<void> initData() async {
    log("Data loading from local database...");
    data = realm.all<Model>();
    log("Data loaded successfully!");
  }

  void handleConnection(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      log("Device disconnected from Internet!");
      Fluttertoast.showToast(
        msg: "Disconnected from Internet",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    } else {
      log("Device connected to Internet!");
      Fluttertoast.showToast(
        msg: "Connected to Internet",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.lightGreen,
      );
      connectToServer();
    }
  }

  Future<void> connectToServer() async {
    try {
      log("Connecting to server...");
      socket = WebSocketChannel.connect(Uri.parse(SERVER_WS));
      await socket.ready;

      socket.stream.listen(
        handleServerEvent,
        onDone: () {
          log("Server connection was closed!");
          isConnected = false;
        },
        onError: (e) {
          log("$e");
        },
      );

      log("Server connection was established!");
      isConnected = true;

      syncDB();
    } on SocketException catch (e) {
      log("Server connection could not be established! The following error was thrown: $e");
      isConnected = false;
    } catch (e) {
      log("Could not connect to server! The following error was thrown: $e");
      isConnected = false;
    }
  }

  Future<void> reconnectToServer() async {
    if (!isConnected) {
      isLoading = true;
      notifyListeners();

      log("Reconnecting to server...");
      connectToServer().then((_) {
        if (!isConnected) {
          log("Reconnection failed!");
        }
        isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> syncDB() async {
    log("Syncing with server...");
    await pushDBChanges();
    log("Local changes were pushed to the server!");
    await pullDBChanges();
    log("Remote changes were pull from the server!");
    log("Syncing finished!");

    notifyListeners();
  }

  Future<void> pushDBChanges() async {
    // get all out of sync items
    final items = realm.all<Model>().where((item) => dataOutOfSync.contains(item.id));

    // push items to the server TODO
    for (final item in items) {
      final requestBody = {
        "name": item.name,
        "organizer": "mathe",
        "category": "fun",
        "capacity": 10,
        "registered": 0,
      };
      await http.post(
        Uri.parse("$SERVER_HTTP/event"),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );
    }

    // clear out of sync data
    dataOutOfSync.clear();
  }

  Future<void> pullDBChanges() async {
    // clear all local data
    realm.write(() {
      realm.deleteAll<Model>();
    });

    // fetch all items from the server TODO
    final items = await http.get(Uri.parse("$SERVER_HTTP/events")).then((response) => jsonDecode(response.body));
    for (final itemData in items) {
      var item = Model(itemData["id"], itemData["name"]);
      realm.write(() {
        realm.add(item);
      });
    }
  }

  void handleServerEvent(message) {
    log("Message received from server: $message");
    final body = jsonDecode(message);

    // TODO
    var item = Model(body["id"], body["name"]);
    realm.write(() {
      realm.add(item);
    });

    // log("The received item with id ${item.id} was added to the local db");
    notifyListeners();
  }

  Model? find(int id) {
    return realm.find<Model>(id);
  }

  Future<void> create(String name) async {
    isLoading = true;
    notifyListeners();

    // TODO
    try {
      int id; // id of the new item

      if (isConnected) {
        final requestBody = {
          "name": name,
          "organizer": "mathe",
          "category": "fun",
          "capacity": 10,
          "registered": 0,
        };
        final responseBody = await http.post(
          Uri.parse("$SERVER_HTTP/event"),
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"},
        ).then((response) => jsonDecode(response.body));

        id = responseBody["id"];
      } else {
        // find maximum id
        final maxId = data.reduce((value, item) {
          if (value.id > item.id) {
            return value;
          }
          return item;
        }).id;

        // assign id
        id = maxId + 1;

        // add item to local db
        var item = Model(id, name);
        realm.write(() {
          realm.add(item);
        });

        // mark the new item as out of sync
        dataOutOfSync.add(item.id);
      }

      log("Created item with id $id");
    } on RealmException catch (e) {
      log("ExamAppException: Item could not be created! The following error was thrown: $e");
      throw ExamAppException("Item could not be created!");
    } on http.ClientException catch (e) {
      log("ExamAppException: Item could not be created! The following error was thrown: $e");
      throw ExamAppException("Item could not be created!");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, String name) async {
    if (!isConnected) {
      throw ExamAppException("Operation requires connection to Internet!");
    }

    isLoading = true;
    notifyListeners();

    // find item
    var item = find(id);
    if (item == null) {
      log("Item with $id was not found!");
      return;
    }

    // update item TODO
    try {
      final requestBody = {
        "name": name,
        "organizer": "mathe",
        "category": "fun",
        "capacity": 10,
        "registered": 0,
      };
      await http.put(
        Uri.parse("$SERVER_HTTP/event"),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      ).then((response) => log(response.body));

      realm.write(() {
        item.name = name;
      });

      log("Updated item with id $id");
    } on RealmException catch (e) {
      log("ExamAppException: Item could not be updated! The following error was thrown: $e");
      throw ExamAppException("Item could not be updated!");
    } on http.ClientException catch (e) {
      log("ExamAppException: Item could not be updated! The following error was thrown: $e");
      throw ExamAppException("Item could not be updated!");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    if (!isConnected) {
      throw ExamAppException("Operation requires connection to Internet!");
    }

    isLoading = true;
    notifyListeners();

    // find item
    var item = find(id);
    if (item == null) {
      log("Item with $id was not found!");
      return;
    }

    // delete item TODO
    try {
      await http.delete(Uri.parse("$SERVER_HTTP/event")).then((response) => log(response.body));

      realm.write(() {
        realm.delete(item);
      });

      log("Deleted item with id $id");
    } on RealmException catch (e) {
      log("ExamAppException: Item could not be deleted! The following error was thrown: $e");
      throw ExamAppException("Item could not be deleted!");
    } on http.ClientException catch (e) {
      log("ExamAppException: Item could not be deleted! The following error was thrown: $e");
      throw ExamAppException("Item could not be deleted!");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}