import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
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
    Key key,
    this.state,
    this.onDismiss,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _boardAnimations(context);

  List<Widget> _fullscreenAnimation({
    Duration duration,
    String filename,
    String animation,
    Color beginColor,
    Color endColor,
    VoidCallback onDismiss,
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
        FlareActor(
          filename,
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
          beginColor: Colors.red.withOpacity(0.4),
          endColor: Colors.red.withOpacity(0.1),
          duration: Duration(milliseconds: 1500),
          onDismiss: onDismiss,
        ),
      // hack for integration test to tap when everything is open
      GestureDetector(
          key: Key('safeTap'),
          onTap: () {},
          child: SizedBox(
            width: 1,
            height: 1,
          )),
    ]);
  }
}
