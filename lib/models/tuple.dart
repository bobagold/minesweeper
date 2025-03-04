import 'dart:async';

/// last 2 items of 2 streams, same as in rxdart
Stream<(A, B)> latest2<A, B>(Stream<A> a, Stream<B> b) {
  var output = StreamController<(A, B)>();
  A? lastA;
  B? lastB;
  a.listen((value) {
    lastA = value;
    if (lastB != null) {
      output.add((lastA!, lastB!));
    }
  });
  b.listen((value) {
    lastB = value;
    if (lastA != null) {
      output.add((lastA!, lastB!));
    }
  });
  return output.stream;
}
