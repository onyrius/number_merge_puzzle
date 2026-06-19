/// Representa uma posição (linha, coluna) dentro do tabuleiro.
/// Substitui o uso de Point por algo com nomes de domínio claros.
class TilePosition {
  final int row;
  final int col;

  const TilePosition(this.row, this.col);

  @override
  // verifica se o outro objeto é do mesmo tipo e tem os mesmos valores de linha e coluna para ser considerado igual.
  bool operator ==(Object other) =>
      other is TilePosition && other.row == row && other.col == col;

  @override
  // Combina o hashCode de row e col para criar um hashCode único para cada combinação de linha e coluna.
  // hashCode é usado para comparar objetos em coleções como Set ou Map, garantindo que objetos com os mesmos valores sejam tratados como iguais.
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'TilePosition($row, $col)';
}
