import 'package:flutter/material.dart';
import 'package:moti_me/authentication/login.dart';
import 'package:moti_me/authentication/signup.dart';
import 'package:go_router/go_router.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/database/ref_helper.dart';
import 'package:moti_me/database/rem_helper.dart';
import 'package:moti_me/profile.dart';
import 'package:moti_me/theme.dart';
import 'package:provider/provider.dart';
import 'database/task_helper.dart';
import 'tabs/Reflection.dart';
import 'tabs/Reminder.dart';
import 'tabs/Tasks.dart';
import 'tabs/Shop.dart';
import 'themes.dart';

final dbHelper = DbHelper();
final refHelper = RefHelper();
final remHelper = RemHelper();
final taskHelper = TaskHelper();
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final List<dynamic> tabs = [
  Reflection(refHelper: refHelper, dbHelper: dbHelper),
  Task(taskHelper: taskHelper, dbHelper: dbHelper),
  Reminder(
    remHelper: remHelper,
    dbHelper: dbHelper,
  ),
  const Shop(),
];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.initParse();
  var userProvider = UserProvider();
  await userProvider.checkLogin();
  runApp(ChangeNotifierProvider(
      create: (_) => userProvider, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  final MaterialTheme mat = const MaterialTheme(TextTheme());

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return MaterialApp.router(
        theme: widget.mat.light(),
        darkTheme: widget.mat.dark(),
        themeMode: ThemeMode.system,
        routerConfig: GoRouter(
            initialLocation: '/login',
            redirect: (context, state) async {
              final isLoggedIn = userProvider.isLoggedIn;
              final loggingIn = state.matchedLocation == '/login';
              if (isLoggedIn && loggingIn) {
                await dbHelper.initUserData(refHelper, remHelper, taskHelper);
                return '/task';
              }
              return null;
            },
            navigatorKey: _rootNavigatorKey,
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, routerState) =>
                    LoginPage(dbHelper: dbHelper),
                routes: [
                  GoRoute(
                    path: 'signup',
                    builder: (context, routerState) =>
                        SignUpPage(dbHelper: dbHelper),
                  ),
                ],
              ),
              StatefulShellRoute.indexedStack(
                builder: (context, state, navigationShell) {
                  return ScaffoldWithNavigationBar(
                    navigationShell: navigationShell,
                  );
                },
                branches: [
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/ref',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: tabs[0],
                        ),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/task',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: tabs[1],
                        ),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/rem',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: tabs[2],
                        ),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/shop',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: tabs[3],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      );
    });
  }
}

class ScaffoldWithNavigationBar extends StatefulWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavigationBar> createState() =>
      _ScaffoldWithNavigationBarState();
}

class _ScaffoldWithNavigationBarState extends State<ScaffoldWithNavigationBar> {
  final PageController _pageController = PageController(initialPage: 1);

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverOverlapAbsorber(
            handle: SliverOverlapAbsorberHandle(),
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: Theme.of(context).primaryColor,
                actionsIconTheme: Theme.of(context).iconTheme,
                actions: <Widget>[
                  IconButton(
                    color: Colors.black,
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await dbHelper.userLogout(
                          refHelper, remHelper, taskHelper);
                      if (context.mounted) {
                        await Provider.of<UserProvider>(context, listen: false)
                            .logout();
                      }
                    },
                  ),
                ],
                leadingWidth: 200,
                leading: Themes.headlineLarge('MotiMe', context),
                pinned: true,
                floating: true,
                snap: true,
                stretch: true,
                expandedHeight: 200,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColorLight,
                      ],
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    stretchModes: const <StretchMode>[
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: profile(dbHelper: dbHelper),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: PageView(
              controller: _pageController,
              onPageChanged: (newIndex) {
                _goBranch(newIndex);
              },
              children: [
                tabs[0],
                tabs[1],
                tabs[2],
                tabs[3],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Theme.of(context).primaryColor,
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            label: 'Reflections',
            icon: Icon(Icons.add_box),
          ),
          NavigationDestination(
            label: 'Tasks',
            icon: Icon(Icons.check_circle_outline),
          ),
          NavigationDestination(
            label: 'Reminders',
            icon: Icon(Icons.alarm),
          ),
          NavigationDestination(
            label: 'Shop',
            icon: Icon(Icons.shopping_cart),
          ),
        ],
        onDestinationSelected: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
