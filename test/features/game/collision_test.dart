import 'dart:ui';

import 'package:flutter_dvmatyun/features/game/presentation/game_rect_screen.dart';
import 'package:flutter_test/flutter_test.dart';

CollisionRectObject _object(int id, Rect rect) =>
    CollisionRectObject(id: id, rect: rect, velocity: Vector2d.zero());

void main() {
  group('CollisionUtil.intercectRects', () {
    test('returns null for separated rects', () {
      final a = _object(0, const Rect.fromLTWH(0, 0, 10, 10));
      final b = _object(1, const Rect.fromLTWH(20, 0, 10, 10));
      expect(CollisionUtil.intercectRects(a, b), isNull);
    });

    test('returns null for touching rects', () {
      final a = _object(0, const Rect.fromLTWH(0, 0, 10, 10));
      final b = _object(1, const Rect.fromLTWH(10, 0, 10, 10));
      expect(CollisionUtil.intercectRects(a, b), isNull);
    });

    test('returns depth and normal pointing from b to a', () {
      final a = _object(0, const Rect.fromLTWH(0, 0, 10, 10));
      final b = _object(1, const Rect.fromLTWH(7, 1, 10, 10));
      final result = CollisionUtil.intercectRects(a, b)!;
      expect(result.depth, closeTo(3, 1e-9));
      expect(result.normal.x, closeTo(-1, 1e-9));
      expect(result.normal.y, closeTo(0, 1e-9));
    });
  });

  test('objects are identified by id only', () {
    final a = _object(0, const Rect.fromLTWH(0, 0, 10, 10));
    final hash = a.hashCode;
    a.rect = a.rect.shift(const Offset(5, 5));
    expect(a.hashCode, hash);
    expect(a, _object(0, Rect.zero));
    expect(a, isNot(_object(1, a.rect)));
  });

  test('immovable objects have zero inverse mass', () {
    expect(_object(0, const Rect.fromLTWH(0, 0, 128, 1024)).inverseMass, 0);
    expect(_object(1, const Rect.fromLTWH(0, 0, 64, 64)).inverseMass, 1 / 4096);
  });
}
