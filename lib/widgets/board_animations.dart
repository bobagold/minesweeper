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
        RiveAnimation.asset(
          filename,
          animations: [animation],
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
          animation: 'Untitled',
          beginColor: Colors.transparent,
          endColor: Colors.black12,
          duration: Duration(seconds: 2),
          onDismiss: onDismiss,
        ),
      if (state == GameState.lost)
        ..._fullscreenAnimation(
          filename: 'assets/lost-fullscreen.flr',
          animation: 'estrellas',
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
