// import 'dart:math';
// import 'package:collection/collection.dart';
// import 'package:number_merge_puzzle/features/domain/utils/matrix_extensions.dart';

// import '../value_objects/direction.dart';

// class GameBoardEntity {
//   static const int defaultGridSize = 4;

//   final List<List<int>> matrix;
//   final int score;
//   final int gridSize;
//   final bool isGameOver;

//   const GameBoardEntity({
//     required this.matrix,
//     required this.score,
//     required this.gridSize,
//     this.isGameOver = false,
//   });

//   factory GameBoardEntity.empty({int size = defaultGridSize}) {
//     return GameBoardEntity(
//       matrix: List.generate(size, (_) => List.generate(size, (_) => 0)),
//       score: 0,
//       isGameOver: false,
//       gridSize: size,
//     );
//   }

//   GameBoardEntity copyWith({
//     List<List<int>>? matrix,
//     int? score,
//     int? gridSize,
//     bool? isGameOver,
//   }) {
//     return GameBoardEntity(
//       matrix: matrix ?? this.matrix,
//       score: score ?? this.score,
//       gridSize: gridSize ?? this.gridSize,
//       isGameOver: isGameOver ?? this.isGameOver,
//     );
//   }

//   // 3. O roteador de movimentos
//   GameBoardEntity move(Direction direction) {
//     // 1. Executa o movimento geométrico
//     GameBoardEntity movedBoard;
//     switch (direction) {
//       case Direction.left:
//         movedBoard = _moveLeft();
//         break;
//       case Direction.right:
//         movedBoard = _moveRight();
//         break;
//       case Direction.up:
//         movedBoard = _moveUp();
//         break;
//       case Direction.down:
//         movedBoard = _moveDown();
//         break;
//     }

//     // 2. Função auxiliar para checar se a matriz mudou após o movimento
//     final Function eq = const DeepCollectionEquality().equals;
//     bool didMove = !eq(movedBoard.matrix, matrix);

//     // Se o movimento não alterou nada no tabuleiro, ignora a jogada
//     if (!didMove) return this;

//     // 3. Coloca o bloco aleatório no tabuleiro movido
//     final finalBoard = movedBoard.spawnRandomTile();

//     // 4. Checa se o jogo acabou após o surgimento do novo bloco e devolve o estado final
//     return finalBoard.copyWith(isGameOver: _checkGameOver(finalBoard.matrix));
//   }

//   // 4. O motor matemático purificado (Esquerda)
//   GameBoardEntity _moveLeft() {
//     List<List<int>> newMatrix = [];
//     int pointsGained = 0;

//     for (var row in matrix) {
//       // Etapa 1: Remover os zeros (Compactar)
//       var compressed = row.where((tile) => tile != 0).toList();

//       // Etapa 2: Fundir vizinhos iguais
//       List<int> merged = [];
//       for (int i = 0; i < compressed.length; i++) {
//         if (i < compressed.length - 1 && compressed[i] == compressed[i + 1]) {
//           int newValue = compressed[i] * 2;
//           merged.add(newValue);
//           pointsGained += newValue;
//           i++; // Pula o vizinho fundido
//         } else {
//           merged.add(compressed[i]);
//         }
//       }

//       // Etapa 3: Preencher com zeros até o tamanho da grade
//       while (merged.length < gridSize) {
//         merged.add(0);
//       }
//       newMatrix.add(merged);
//     }

//     return copyWith(matrix: newMatrix, score: score + pointsGained);
//   }

//   // 5. Truques geométricos para as outras direções
//   // Para mover para a direita, invertemos as linhas, aplicamos a lógica de movimento para a esquerda e depois invertemos novamente.
//   GameBoardEntity _moveRight() {
//     var reversedMatrix = matrix.reverse();
//     var moved = GameBoardEntity(
//       matrix: reversedMatrix,
//       score: score,
//       gridSize: gridSize,
//     )._moveLeft();
//     return copyWith(matrix: moved.matrix.reverse(), score: moved.score);
//   }

//   // Para mover para cima, transpondo a matriz, aplicando a lógica de movimento para a esquerda e depois transpondo novamente.
//   GameBoardEntity _moveUp() {
//     var transposed = matrix.transpose(gridSize);
//     var moved = GameBoardEntity(
//       matrix: transposed,
//       score: score,
//       gridSize: gridSize,
//     )._moveLeft();
//     return copyWith(
//       matrix: moved.matrix.transpose(gridSize),
//       score: moved.score,
//     );
//   }

//   // Para mover para baixo, transpondo a matriz, invertemos, aplicamos a lógica de movimento para a esquerda e depois transpondo novamente.
//   GameBoardEntity _moveDown() {
//     var transposed = matrix.transpose(gridSize);
//     var reversed = transposed.reverse();
//     var moved = GameBoardEntity(
//       matrix: reversed,
//       score: score,
//       gridSize: gridSize,
//     )._moveLeft();
//     var unReversed = moved.matrix.reverse();
//     return copyWith(matrix: unReversed.transpose(gridSize), score: moved.score);
//   }

//   // 6. Gerar um novo bloco aleatório
//   GameBoardEntity spawnRandomTile() {
//     // Point é uma classe do Dart que representa um ponto 2D, com coordenadas x e y.
//     List<Point<int>> emptyPositions = [];

//     // 1. Encontra todas as posições vazias (onde o valor é 0)
//     for (int rowIndex = 0; rowIndex < gridSize; rowIndex++) {
//       for (int columnIndex = 0; columnIndex < gridSize; columnIndex++) {
//         if (matrix[rowIndex][columnIndex] == 0) {
//           emptyPositions.add(Point(rowIndex, columnIndex));
//         }
//       }
//     }

//     // Se não há espaço vazio, retorna o próprio tabuleiro sem alterações
//     if (emptyPositions.isEmpty) return this;

//     // 2. Sorteia uma posição da lista
//     // nextInt(length) retorna um inteiro aleatório entre 0 (inclusive) e length (exclusive), garantindo que a posição sorteada seja válida dentro da lista de posições vazias.
//     final random = Random();
//     final randomPosition =
//         emptyPositions[random.nextInt(emptyPositions.length)];

//     // 3. Sorteia um número quebrado entre 0.0 e 1.0
//     final chance = random.nextDouble();
//     final int tileValue;

//     if (chance < 0.80) {
//       tileValue = 2; // 80% de chance (de 0.0 até 0.79)
//     } else if (chance < 0.95) {
//       tileValue = 4; // 15% de chance (de 0.80 até 0.94)
//     } else {
//       tileValue = 8; // 5% de chance (de 0.95 até 1.0)
//     }

//     // 4. Cria uma cópia da matriz atual para aplicar a alteração com segurança
//     List<List<int>> newMatrix = matrix
//         .map((row) => List<int>.from(row))
//         .toList();
//     newMatrix[randomPosition.x][randomPosition.y] = tileValue;

//     // 5. Retorna o novo estado com o bloco inserido
//     return copyWith(matrix: newMatrix);
//   }

//   bool _checkGameOver(List<List<int>> grid) {
//     // 1. Se ainda existir alguma casa vazia, o jogo NÃO acabou
//     for (int rowIndex = 0; rowIndex < gridSize; rowIndex++) {
//       for (int columnIndex = 0; columnIndex < gridSize; columnIndex++) {
//         if (grid[rowIndex][columnIndex] == 0) return false;
//       }
//     }

//     // 2. Verifica se existem blocos iguais vizinhos na horizontal ou vertical
//     for (int rowIndex = 0; rowIndex < gridSize; rowIndex++) {
//       for (int columnIndex = 0; columnIndex < gridSize; columnIndex++) {
//         int current = grid[rowIndex][columnIndex];

//         // Tem vizinho igual na direita?
//         if (columnIndex < gridSize - 1 &&
//             current == grid[rowIndex][columnIndex + 1]) {
//           return false;
//         }
//         // Tem vizinho igual embaixo?
//         if (rowIndex < gridSize - 1 &&
//             current == grid[rowIndex + 1][columnIndex]) {
//           return false;
//         }
//       }
//     }

//     // Se passou por tudo e não achou espaços ou combinações, o jogo acabou!
//     return true;
//   }
// }
