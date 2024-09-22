extension ListUtils<T> on List<T> {
  List<T> interspersed(T separator) {
    if (isEmpty) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        if (i > 0) separator,
        this[i],
      ]
    ];
  }
}
