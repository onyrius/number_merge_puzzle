import 'package:flutter/services.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

/// Traduz eventos de teclado físico em comandos de domínio (Direction).
/// É "infraestrutura" porque depende de detalhes externos (o pacote
/// flutter/services) que não deveriam vazar para o domínio.
class KeyboardInputHandler {
  Direction? mapKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return null;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) return Direction.left;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return Direction.right;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) return Direction.up;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) return Direction.down;

    return null;
  }
}
