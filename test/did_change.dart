import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ParentWidget());
  }
}

// 1. Inherited Widget to test didChangeDependencies
class MyInheritedTheme extends InheritedWidget {
  final Color color;

  const MyInheritedTheme({super.key, required this.color, required super.child});

  static MyInheritedTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedTheme>();
  }

  @override
  bool updateShouldNotify(MyInheritedTheme oldWidget) {
    // Notify dependents if the color changes
    return color != oldWidget.color;
  }
}

// 2. Parent Widget to hold state and Trigger Changes
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int _counter = 0;
  Color _themeColor = Colors.blue;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleThemeColor() {
    setState(() {
      _themeColor = _themeColor == Colors.blue ? Colors.red : Colors.blue;
    });
  }

  @override
  void didUpdateWidget(covariant ParentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('--------- Parent didUpdateWidget triggered ---------');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
 //   print('--------- Parent didChangeDependencies triggered ---------');
  }

  @override
  void initState() { 
    super.initState();
    print("initState");
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedTheme(
      color: _themeColor,
      child: Scaffold(
        appBar: AppBar(title: const Text('Testing Lifecycle Methods')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The child widget where we will test the lifecycle methods
              DidChangeTargetWidget(counter: _counter),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text('Trigger didUpdateWidget (Change Counter)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleThemeColor,
                child: const Text(
                  'Trigger didChangeDependencies (Change Inherited Color)',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. Child Widget implementing the lifecycle methods we want to test
class DidChangeTargetWidget extends StatefulWidget {
  final int counter;

  const DidChangeTargetWidget({super.key, required this.counter});

  @override
  State<DidChangeTargetWidget> createState() => _DidChangeTargetWidgetState();
}

class _DidChangeTargetWidgetState extends State<DidChangeTargetWidget> {
  Color? _currentColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is called when the widget is first created and when
    // an inherited widget it depends on (like MyInheritedTheme) changes.
    print('--------- didChangeDependencies triggered ---------');

    // We establish a dependency on MyInheritedTheme here:
    final inheritedTheme = MyInheritedTheme.of(context);
    _currentColor = inheritedTheme?.color;
  }

  @override
  void didUpdateWidget(covariant DidChangeTargetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is called when the parent widget rebuilds and provides new configuration (new widget instance) to this location in the tree.
    print('--------- didUpdateWidget triggered ---------');

    if (oldWidget.counter != widget.counter) {
      print('Counter changed from ${oldWidget.counter} to ${widget.counter}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build triggered');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _currentColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
        border: Border.all(color: _currentColor ?? Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Target Widget',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text('Counter Value: ${widget.counter}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            'Theme Color Updated!',
            style: TextStyle(color: _currentColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
