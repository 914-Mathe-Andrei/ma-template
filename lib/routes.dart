import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:template/repo/repository.dart';
import 'package:template/models/models.dart';
import 'package:template/pages/home_page.dart';
import 'package:template/pages/other_page.dart';
import 'package:template/pages/create_page.dart';
import 'package:template/pages/detail_page.dart';
import 'package:template/pages/update_page.dart';

enum Routes {
  home("home", "/"),
  page("page", "/page"),
  create("create", "/create"),
  detail("detail", "/detail/:id"),
  update("update", "/update/:id");

  const Routes(this.name, this.path);

  final String name;
  final String path;
}

final router = GoRouter(initialLocation: "/", routes: [
  GoRoute(
    name: Routes.home.name,
    path: Routes.home.path,
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
        transitionsBuilder: (_, __, ___, ____) => const HomePage(),
        transitionDuration: Duration.zero,
      );
    },
  ),
  GoRoute(
    name: Routes.page.name,
    path: Routes.page.path,
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        key: state.pageKey,
        child: const OtherPage(),
        transitionsBuilder: (_, __, ___, ____) => const OtherPage(),
        transitionDuration: Duration.zero,
      );
    },
  ),
  GoRoute(
    name: Routes.create.name,
    path: Routes.create.path,
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        key: state.pageKey,
        child: const CreatePage(),
        transitionsBuilder: (_, __, ___, ____) => const CreatePage(),
        transitionDuration: Duration.zero,
      );
    },
  ),
  GoRoute(
    name: Routes.detail.name,
    path: Routes.detail.path,
    pageBuilder: (context, state) {
      if (!state.pathParameters.containsKey("id")) {
        // this should not happen
        assert(false);
      }

      int id = int.parse(state.pathParameters["id"]!);
      Model? item = Provider.of<Repository>(context, listen: false).find(id);

      return CustomTransitionPage(
        key: state.pageKey,
        child: DetailPage(item: item!),
        transitionsBuilder: (_, __, ___, ____) => DetailPage(item: item),
        transitionDuration: Duration.zero,
      );
    },
  ),
  GoRoute(
    name: Routes.update.name,
    path: Routes.update.path,
    pageBuilder: (context, state) {
      if (!state.pathParameters.containsKey("id")) {
        // this should not happen
        assert(false);
      }

      int id = int.parse(state.pathParameters["id"]!);
      Model? item = Provider.of<Repository>(context, listen: false).find(id);

      return CustomTransitionPage(
        key: state.pageKey,
        child: UpdatePage(item: item!),
        transitionsBuilder: (_, __, ___, ____) => UpdatePage(item: item),
        transitionDuration: Duration.zero,
      );
    },
  ),
]);