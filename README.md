# Flutter-starter
Flutter first app: https://codelabs.developers.google.com/codelabs/flutter-codelab-first

## Flutter Experience & Notes
* It tried to create its own root. I'll let it be for now.

### Widgets
"Everything is a Widget."

That sounds similar to saying "in React, everything is a Component" or "in Java, everything is a Class". And in a way, that's true. Widgets are modular, reusable, extensible, and oftentimes a Widget is just a container of other Widgets and some description of how they fit together.

Widgets seem to take things a bit further. Where React has you using CSS to design and decorate Components, Flutter actually does this _with more Widgets_. For example. `Center` and `Opacity` are themselves Widgets, not attributes you assign through CSS or some other _association_ with the Widget you're building. Even strings to display are `Text` widgets.

But that's just __some__ of the time. Widgets do have attributes as well: their `height`, or `mainAxisAlignment`, or `label`, etc. So it's not exactly clear yet what behaviors will require a Widget, and what can be changed with an attribute.

#### Rendering
   * Widgets call `build` to render/re-render
   * `build` returns widget(s) (one widget, or a nested tree of widgets)

### State
  * Generally: `StatefulWidget`s use state, `StatelessWidget`s don't. There are probably others that deal with asynchronous states, responsiveness, and the like. These are extensible.
  * `BuildContext` declares state
  * context.`watch<StaneName>` declares state reliance

### Flutter Flavor
1. Prefers Composition over Inheritance. Make things like frames, padding, etc. their own widgets. This lets a widget focus on its own singular responsibility.
2.
