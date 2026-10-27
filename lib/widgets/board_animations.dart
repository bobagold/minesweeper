import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../models/game.dart';

/// board animations
class BoardAnimations extends StatelessWidget {
  /// game state
  final GameState state;

  /// child widget (usually, board)
  final Widget child;

  /// onDismiss callback
  final VoidCallback onDismiss;

  /// constructor
  const BoardAnimations({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => _boardAnimations(context);

  List<Widget> _fullscreenAnimation({
    required Duration duration,
    required String filename,
    required String animation,
    required Color beginColor,
    required Color endColor,
    required VoidCallback onDismiss,
  }) =>
      [
        TweenAnimationBuilder(
          tween: ColorTween(
            begin: beginColor,
            end: endColor,
          ),
          duration: duration,
          builder: (context, color, _) => ModalBarrier(
            color: color,
          ),
        ),
        _EndGameAnimation(
          key: ValueKey(filename),
          filename: filename,
          animation: animation,
        ),
        GestureDetector(
          onTap: onDismiss,
        ),
      ];

  Widget _boardAnimations(BuildContext context) {
    return Stack(children: [
      child,
      if (state == GameState.win)
        ..._fullscreenAnimation(
          filename: 'assets/win-fullscreen.flr',
          animation: 'Timeline 1',
          beginColor: Colors.transparent,
          endColor: Colors.black12,
          duration: Duration(seconds: 2),
          onDismiss: onDismiss,
        ),
      if (state == GameState.lost)
        ..._fullscreenAnimation(
          filename: 'assets/lost-fullscreen.flr',
          animation: 'Timeline 1',
          beginColor: Colors.red.withAlpha(102),
          endColor: Colors.red.withAlpha(25),
          duration: Duration(milliseconds: 1500),
          onDismiss: onDismiss,
        ),
      // hack for integration test to tap when everything is open
      InkWell(
          key: Key('safeTap'),
          onTap: () {},
          child: SizedBox(
            width: 1,
            height: 1,
          )),
    ]);
  }
}

class _EndGameAnimation extends StatefulWidget {
  final String filename;
  final String animation;

  const _EndGameAnimation({
    super.key,
    required this.filename,
    required this.animation,
  });

  @override
  State<_EndGameAnimation> createState() => _EndGameAnimationState();
}

class _EndGameAnimationState extends State<_EndGameAnimation> {
  File? _file;
  Artboard? _artboard;
  late final SingleAnimationPainter _painter =
      SingleAnimationPainter(widget.animation);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await RiveNative.init();
    var file = await File.asset(widget.filename, riveFactory: Factory.flutter);
    if (!mounted) {
      file?.dispose();
      return;
    }
    if (file == null) {
      throw StateError('Cannot decode animation: ${widget.filename}');
    }
    setState(() {
      _file = file;
      _artboard = file.defaultArtboard();
    });
  }

  @override
  void dispose() {
    _painter.dispose();
    _artboard?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _artboard == null
      ? SizedBox.shrink()
      : RiveArtboardWidget(artboard: _artboard!, painter: _painter);
}
