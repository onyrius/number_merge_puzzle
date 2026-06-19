// Métodos auxiliares de matriz
// reverse é usado para inverter as linhas, e transpose para trocar linhas por colunas, facilitando os movimentos em outras direções.
extension MatrixExtensions on List<List<int>> {
  List<List<int>> transpose(int size) {
    return List.generate(
      size,
      (col) => List.generate(size, (row) => this[row][col]),
    );
  }

  List<List<int>> reverse() {
    return map((row) => row.reversed.toList()).toList();
  }
}
