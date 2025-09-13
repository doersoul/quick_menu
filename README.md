# quick_menu
Long press to display quick menu in flutter app

# Screenshots
|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/1.png)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/2.png)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/3.png)|
|:---:|:---:|:---:|
|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/4.png)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/5.png)||

# Usage
```yaml
dependencies:
  flutter:
    sdk: flutter
  quick_menu: any
```

```dart
QuickMenu(
  menu: menu,
  child: child,
);
```

# Example
```dart
import 'package:flutter/material.dart';
import 'package:quick_menu/quick_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: const ColorScheme.light()),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Quick Menu Demo'),
      ),
      body: Column(
        children: [
          const ChatItem(),
          const ChatItem(),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: 16,
              itemBuilder: (ctx, idx) {
                return const Center(child: MenuItem());
              },
            ),
          ),
          const ChatItem(),
          const ChatItem(),
          const ChatItem(),
        ],
      ),
    );
  }
}

class ChatItem extends StatefulWidget {
  const ChatItem({super.key});

  @override
  State<StatefulWidget> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  final QuickMenuController _controller = QuickMenuController();

  Color _color = Colors.transparent;

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _setColor([_]) {
    setState(() {
      _color = Colors.grey.shade100;
    });
  }

  void _resetColor([_]) {
    setState(() {
      _color = Colors.transparent;
    });
  }

  void _onTapMenu() {
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final Widget menu = GestureDetector(
      onTap: _onTapMenu,
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Menus')),
      ),
    );

    final Widget child = ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(48),
        ),
      ),
      title: Text('Quick Menu'),
      subtitle: Text('nice to meet you'),
    );

    return Container(
      color: _color,
      child: QuickMenu(
        controller: _controller,
        onTapDown: _setColor,
        onLongPress: _setColor,
        onOpenMenu: _resetColor,
        onTapCancel: _resetColor,
        onTap: _resetColor,
        overlayBuilder: (Widget cld) {
          return ColoredBox(color: Colors.white, child: cld);
        },
        menu: menu,
        child: child,
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  const MenuItem({super.key});

  @override
  State<StatefulWidget> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final QuickMenuController _controller = QuickMenuController();

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _onTapMenu() {
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final Widget menu = GestureDetector(
      onTap: _onTapMenu,
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Menus')),
      ),
    );

    final Widget child = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(64),
        color: Colors.teal,
      ),
      child: Icon(Icons.sunny),
    );

    return QuickMenu(
      controller: _controller,
      overlayRadius: null,
      overlayScaleIncrement: 0.5,
      menu: menu,
      child: child,
    );
  }
}
```