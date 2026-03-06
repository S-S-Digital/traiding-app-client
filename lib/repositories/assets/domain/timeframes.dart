class Timeframes {
  Timeframes({required this.title, required this.value});
  final String title;
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timeframes && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
