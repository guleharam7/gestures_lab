import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const GestureLabApp());
}

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Lab',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class AppState extends ChangeNotifier {
  int counter = 0;
  String lastGesture = 'None yet';
  Offset boxOffset = Offset.zero;
  double boxScale = 1.0;
  Color padColor = Colors.indigo;

  void tap() {
    counter++;
    lastGesture = 'Tap';
    notifyListeners();
  }

  void doubleTap() {
    counter += 2;
    lastGesture = 'Double Tap';
    notifyListeners();
  }

  void longPress() {
    List<Color> colors = [Colors.indigo, Colors.red, Colors.purple];
    padColor = colors[Random().nextInt(colors.length)];
    lastGesture = 'Long Press';
    notifyListeners();
  }

  void moveAndScale(Offset delta, double scale) {
    boxOffset += delta;
    boxScale = scale.clamp(0.5, 3.0);
    lastGesture = 'Drag / Pinch';
    notifyListeners();
  }

  void swipe(bool right) {
    counter += right ? 10 : -10;
    lastGesture = right ? 'Swipe Right' : 'Swipe Left';
    notifyListeners();
  }
}

final AppState appState = AppState();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context,_){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Counter: ${appState.counter} | Last: ${appState.lastGesture}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: appState.tap,
                  onDoubleTap: appState.doubleTap,
                  onLongPress: appState.longPress,
                  child: Container(
                    width: 220,
                    height: 220,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appState.padColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Gesture Pad\nTap / Double Tap / Hold',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlaygroundScreen()),
                    );
                  },
                  child: const Text('Open Playground'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
      ),

      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return Column(
            children: [
              const SizedBox(height: 16),

              Text(
                'Counter: ${appState.counter} | Last: ${appState.lastGesture}',
                style: const TextStyle(fontSize: 18),
              ),

              Expanded(
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseScale = appState.boxScale;
                  },

                  onScaleUpdate: (details) {
                    appState.moveAndScale(
                      details.focalPointDelta,
                      _baseScale * details.scale,
                    );
                  },

                  child: Container(
                    color: Colors.indigo.shade50,
                    width: double.infinity,

                    child: Center(
                      child: Transform.translate(
                        offset: appState.boxOffset,

                        child: Transform.scale(
                          scale: appState.boxScale,

                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.teal,
                            alignment: Alignment.center,

                            child: const Text(
                              'Drag / Pinch',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onHorizontalDragEnd: (details) {
                  appState.swipe(
                    details.primaryVelocity! > 0,
                  );
                },

                child: Card(
                  color: Colors.amber,
                  child: const Padding(
                    padding: EdgeInsets.all(20),

                    child: Text(
                      'Swipe Left or Right',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text('Back to Home'),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
