import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo: Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: MyHomePage(),
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),  // tutorial version
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    // ChangeNotifier.notifyListeners() alerts MyAppState watchers of changes
    notifyListeners();
  }

  void toggleLike() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;  // this is the only state this widget tracks

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
        // `builder` called whenever constraints change
        builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                // responsive trigger
                extended: constraints.maxWidth >= 500,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Like'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  print('selected: $value');
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    // var liked = appState.favorites.contains(pair);
    IconData icon;

    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your dog\'s superspy codename is:'),
          BigCard(pair: pair),
          SizedBox(height: 10), // spacer
          Row(
            mainAxisSize:
                MainAxisSize.min, // for learning. mainAxisAlignment w/b better.
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  print('Like button pressed!');
                  appState.toggleLike();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     print('Favorite (text) button pressed!');
              //     appState.toggleFavorite();
              //   },
              //   child: Text('<3 Favorite'),  // make inline ternary to switch between </3 and <3 ?
              // ),
              SizedBox(width: 10), // spacer
              ElevatedButton(
                onPressed: () {
                  print('Next button pressed!');
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${favorites.length} favorites:'),
        ),
        for (var pair in favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );

    // return Column(
    //   children: [
    //     favorites.map((m) => Text(m))
    //     favorites,
    //   ],
    // );

    // return ListView.builder(
    //   padding: const EdgeInsets.all(8),
    //   itemCount: favorites.length,
    //   itemBuilder: (BuildContext context, int index) {
    //   },
    // );

    // return Container(
    //   height: 50,
    //   child: Center(child: Text('Entry ${favorites[index]}')),
    //   );
    // }
  }
}
