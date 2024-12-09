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
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
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
    // maybe reference for brevity? `var theme = Theme.of(context);`, or `var colorScheme = Theme.of(context).colorScheme;`

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = LikesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 150),
        child: page,
      ),
    );

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
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
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
          Spacer(flex: 2),
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
        child: AnimatedSize(
          duration: Duration(milliseconds: 150),
          // Ensure compound word wraps correctly when window is narrow
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first.toLowerCase(),
                  style: style.copyWith(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  pair.second.toLowerCase(),
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LikesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.likedWords.isEmpty) {
      return Center(
        child: Text('None Liked yet.'),
      );
    }

    // return ListView(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.all(20),
    //       child: Text('You have ${appState.likedWords.length} Liked names:'),
    //     ),
    //     for (var pair in appState.likedWords)
    //       ListTile(
    //         leading: Icon(Icons.favorite),
    //         title: Text(pair.asLowerCase),
    //       ),
    //   ],
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.likedWords.length} Liked names:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              // appState.likedWords.map((pair) => (
              for (var pair in appState.likedWords)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      appState.removeLike(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
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

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  // Needed so that [MyAppState] can tell [AnimatedList] below to animate
  // new items.
  final _key = GlobalKey();

  // Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // gradient from transparent to opaque black...
    colors: [Colors.transparent, Colors.black],
    // ...from the top to the middle
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleLike(pair);
                },
                icon: appState.likedWords.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
