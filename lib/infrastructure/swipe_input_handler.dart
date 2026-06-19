import 'package:flutter/widgets.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

/// Traduz gestos de arrastar (pan) em comandos de domínio (Direction).
/// Mantém o estado de início/fim do gesto, que é um detalhe de UI,
/// fora da camada de domínio e da camada de apresentação.
class SwipeInputHandler {
  Offset? _start;
  Offset? _current;

  static const double _minDragDistance = 10.0;

  void onPanStart(DragStartDetails details) {
    _start = details.globalPosition;
    _current = details.globalPosition;
  }

  void onPanUpdate(DragUpdateDetails details) {
    _current = details.globalPosition;
  }

  /// Retorna a direção do swipe ao soltar o dedo, ou null se o gesto
  /// foi pequeno demais para ser considerado um swipe válido.
  Direction? onPanEnd(DragEndDetails details) {
    if (_start == null || _current == null) return null;

    final delta = _current! - _start!;
    _start = null;
    _current = null;

    if (delta.dx.abs() < _minDragDistance &&
        delta.dy.abs() < _minDragDistance) {
      return null;
    }

    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? Direction.right : Direction.left;
    } else {
      return delta.dy > 0 ? Direction.down : Direction.up;
    }
  }
}
