# quick_menu
Quick menu in app，like 3D touch quick actions

# Screenshots
|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/1.png?raw=true)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/2.png?raw=true)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/3.png?raw=true)|
|:---:|:---:|:---:|
|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/4.png?raw=true)|![](https://github.com/doersoul/quick_menu/blob/main/screenshots/5.png?raw=true)||

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: const ColorScheme.light()),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final ChatItem chatItem = const ChatItem();

    final Widget grid = Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: 16,
        itemBuilder: (ctx, idx) {
          return const Center(child: MenuItem());
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Menu Demo'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [chatItem, chatItem, grid, chatItem, chatItem, chatItem],
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

  late double _screenWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.sizeOf(context).width;
  }

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
    final Widget line = Container(height: 0.1, color: Colors.grey);

    final Widget menuItem = Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Menu'), Icon(Icons.add)],
      ),
    );

    final Widget menu = GestureDetector(
      onTap: _onTapMenu,
      child: SizedBox(
        width: _screenWidth * 0.618,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [menuItem, line, menuItem, line, menuItem]),
        ),
      ),
    );

    final Widget child = ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black,
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
        overlayScaleIncrement: -(16 * 2 / _screenWidth),
        onTapDown: _setColor,
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
    final Widget line = Container(height: 0.1, color: Colors.grey);

    final Widget menuItem = Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Menu'), Icon(Icons.add)],
      ),
    );

    final Widget menu = GestureDetector(
      onTap: _onTapMenu,
      child: SizedBox(
        width: 210,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [menuItem, line, menuItem, line, menuItem]),
        ),
      ),
    );

    final Widget child = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(64),
        color: Colors.black,
      ),
      child: Icon(Icons.sunny, color: Colors.white),
    );

    return QuickMenu(
      controller: _controller,
      overlayRadius: null,
      overlayScaleIncrement: 8 * 2 / 64,
      menu: menu,
      child: child,
    );
  }
}
```
