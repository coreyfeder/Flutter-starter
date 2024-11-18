# Flutter-starter
Flutter first app: https://codelabs.developers.google.com/codelabs/flutter-codelab-first

## Flutter Experience & Notes
* It tried to create its own root. I'll let it be for now.

### Widgets
"Widget" ~= Component

#### Rendering
   * Widgets call `build` to render/re-render
   * `build` returns widget(s) (one widget, or a nested tree of widgets)

### State
  * `BuildContext` inst. declares state
  * context.`watch<StaneName>` declares state reliance

### Flutter Flavor
1. Preferse Composition over Inheritance. Make things like frames, padding, etc. their own widgets. This lets a widget focus on its own singular responsibility.
1.
