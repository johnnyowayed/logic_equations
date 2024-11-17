class MoveState {
  final List<List<String>> gridValues;
  final Map<String, int> letterValues;

  MoveState(this.gridValues, this.letterValues);

  // Deep copy constructor
  MoveState.copy(MoveState other)
      : gridValues = List<List<String>>.from(
    other.gridValues.map((row) => List<String>.from(row)),
  ),
        letterValues = Map<String, int>.from(other.letterValues);
}