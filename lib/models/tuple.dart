import 'dart:async';

/// tuple of 2 variables, like Either
class Tuple2<A, B> {
  /// a
  final A a;

  /// b
  final B b;

  /// constructor
  const Tuple2(this.a, this.b);

  /// like mapLeft
  Tuple2<A, B> withA(A a) => Tuple2(a, b);

  /// like mapRight
  Tuple2<A, B> withB(B b) => Tuple2(a, b);
}

/// last 2 items of 2 streams, same as in rxdart
Stream<Tuple2<A, B>> latest2<A, B>(Stream<A> a, Stream<B> b) {
  var output = StreamController<Tuple2<A, B>>();
  A lastA;
  B lastB;
  a.listen((value) {
    lastA = value;
    if (lastB != null) {
      output.add(Tuple2(lastA, lastB));
    }
  });
  b.listen((value) {
    lastB = value;
    if (lastA != null) {
      output.add(Tuple2(lastA, lastB));
    }
  });
  return output.stream;
}
