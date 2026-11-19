/// Injectable time source so date-dependent logic is deterministic in tests.
class Clock {
  const Clock();
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  const FixedClock(this.fixed);
  final DateTime fixed;

  @override
  DateTime now() => fixed;
}
