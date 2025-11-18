import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StopwatchPage());
  }
}

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late StreamController<int> _tickController;
  late Stream<int> _secondStream;
  Timer? _timer;
  int _ticks = 0;
  bool _running = false;

  // Animazione drago
  int _currentFrameIndex = 0;
  final List<int> _frameOrder = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2];
  double _frogX = 0;
  double _frogSpeed = 5;
  Timer? _frogTimer;

  @override
  void initState() {
    super.initState();
    _tickController = StreamController<int>.broadcast();
    _secondStream = _tickController.stream.map((tick) => tick ~/ 10);
  }

  void _start() {
    if (!_running) {
      _running = true;

      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        _ticks++;
        _tickController.add(_ticks);
      });

      _frogTimer = Timer.periodic(Duration(milliseconds: 80), (timer) {
        setState(() {
          _currentFrameIndex =
              (_currentFrameIndex + 1) % _frameOrder.length;

          _frogX += _frogSpeed;

          if (_frogX > MediaQuery.of(context).size.width) {
            _frogX = -150;
          }
        });
      });
    }
  }

  void _stop() {
    _timer?.cancel();
    _frogTimer?.cancel();
    _running = false;
  }

  void _reset() {
    _stop();
    _ticks = 0;
    _tickController.add(_ticks);
    setState(() {
      _currentFrameIndex = 0;
      _frogX = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frogTimer?.cancel();
    _tickController.close();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  // PULSANTI
  Widget cloudButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 45, color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- SFONDO ---
          Positioned.fill(
            child: Image.asset(
              'assets/back.jpg',
              fit: BoxFit.cover,
            ),
          ),

          //
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<int>(
                  stream: _secondStream,
                  builder: (context, snapshot) {
                    final seconds = snapshot.data ?? 0;
                    return Text(
                      _formatTime(seconds),
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 6,
                          )
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 180),
              ],
            ),
          ),

          //drago
          Positioned(
            top: MediaQuery.of(context).size.height / 2 + 50,
            left: _frogX,
            child: Image.asset(
              'assets/d${_frameOrder[_currentFrameIndex]}.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),

      //PULSANTI
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          cloudButton(
            icon: Icons.play_arrow,
            onTap: _start,
          ),
          SizedBox(width: 15),
          cloudButton(
            icon: Icons.stop,
            onTap: _stop,
          ),
          SizedBox(width: 15),
          cloudButton(
            icon: Icons.refresh,
            onTap: _reset,
          ),
        ],
      ),
    );
  }
}