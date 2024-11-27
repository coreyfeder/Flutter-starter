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
  var likedWords = <WordPair>[];
  var history = <WordPair>[]; // create a scrollback of all generated wordpairs

  // GlobalKey is very expensive if mishandled.
  // "a good practice is to let a State object own the GlobalKey, and
  // instantiate it outside the build method, such as in [State.initState]"
  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current); // ??: is adding to front more expensive?
    current = WordPair.random();
    // alert MyAppState watchers of change
    notifyListeners();
  }

  void toggleLike([WordPair? pair]) {
    pair = pair ?? current;
    if (likedWords.contains(pair)) {
      likedWords.remove(pair);
    } else {
      likedWords.add(pair);
    }
    notifyListeners();
  }

  void removeLike(WordPair pair) {
    likedWords.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // this is the only state this widget tracks

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

    if (appState.likedWords.contains(pair)) {
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

    if (appState.likedWords.isEmpty) {
      return Center(
        child: Text('No names Liked yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.likedWords.length} Liked names:'),
        ),
        for (var pair in appState.likedWords)
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
