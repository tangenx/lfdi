import 'dart:async';

void Function() debounce(void Function() callback, Duration duration) {
  Timer? timer;
  return () {
    timer?.cancel();
    timer = Timer(duration, callback);
  };
}
