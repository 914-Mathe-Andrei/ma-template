import 'package:realm/realm.dart';

part 'models.g.dart';

@RealmModel()
class _Model {
  @PrimaryKey()
  late final int id;

  late String name;
}