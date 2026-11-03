import 'dart:collection';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dvmatyun/features/game/presentation/game_rect_camera.dart';
import 'package:repaint/repaint.dart';

/// {@template quadtree_screen}
/// QuadTreeCollisionScreen widget.
/// {@endtemplate}
class GameRectScreen extends StatefulWidget {
  /// {@macro quadtree_screen}
  const GameRectScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<GameRectScreen> createState() => _GameRectScreenState();
}

/// State for widget QuadTreeCollisionScreen.
class _GameRectScreenState extends State<GameRectScreen> {
  final QuadTreeCollisionPainter painter = QuadTreeCollisionPainter();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Game screen'),
      leading: BackButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ),
    body: SafeArea(child: RePaint(painter: painter)),
  );
}

class CollisionRectObject {
  CollisionRectObject({
    required this.id,
    required this.rect,
    required this.velocity,
  });

  final int id;
  Rect rect;
  Vector2d velocity;

  // Only small rects can be moved
  bool get canBeMoved => rect.width < 128 && rect.height < 128;

  /// Inverse of the mass, which is proportional to the area.
  /// Immovable objects have an infinite mass, so their inverse mass is zero.
  double get inverseMass => canBeMoved ? 1 / (rect.width * rect.height) : 0;

  Iterable<Vector2d> get vertices {
    return [
      Vector2d(rect.left, rect.bottom),
      Vector2d(rect.right, rect.bottom),
      Vector2d(rect.right, rect.top),
      Vector2d(rect.left, rect.top),
    ];
  }

  Vector2d get absoluteCenter => Vector2d(rect.center.dx, rect.center.dy);

  // [rect] and [velocity] change every frame,
  // so the identity of an object is its quadtree id only.
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollisionRectObject && id == other.id;
}

class Vector2d {
  const Vector2d(this.x, this.y);

  Vector2d.zero() : x = 0, y = 0;

  final double x;
  final double y;

  /// Negate.
  Vector2d operator -() => Vector2d(-x, -y);

  /// Subtract two vectors.
  Vector2d operator -(Vector2d other) => Vector2d(x - other.x, y - other.y);

  /// Add two vectors.
  Vector2d operator +(Vector2d other) => Vector2d(x + other.x, y + other.y);

  /// Scale.
  Vector2d operator /(double scale) => Vector2d(x / scale, y / scale);

  /// Scale.
  Vector2d operator *(double scale) => Vector2d(x * scale, y * scale);

  /// Length.
  double get length => sqrt(length2);

  /// Length squared.
  double get length2 {
    double sum;
    sum = x * x;
    sum += y * y;
    return sum;
  }

  /// Normalize this.
  Vector2d normalized() {
    final l = length;
    if (l == 0.0) {
      return Vector2d.zero();
    }
    final d = 1.0 / l;
    return Vector2d(x * d, y * d);
  }

  /// Inner product.
  double dot(Vector2d other) {
    double sum;
    sum = x * other.x;
    sum += y * other.y;
    return sum;
  }

  Vector2d perpendicular() => Vector2d(-y, x);

  @override
  String toString() => 'Vector2d($x, $y)';
}

class CollisionUtil {
  /// Separating axis test for two rects.
  /// Returns the collision normal (pointing from [b] to [a]) and
  /// the penetration depth, or null if the rects do not overlap.
  static ({Vector2d normal, double depth})? intercectRects(
    CollisionRectObject a,
    CollisionRectObject b,
  ) {
    Vector2d normal = Vector2d.zero();
    double depth = double.maxFinite;

    final List<Vector2d> verticesA = a.vertices.toList();
    final List<Vector2d> verticesB = b.vertices.toList();

    final normalAndDepthA = CollisionUtil.getNormalAndDepth(
      verticesA,
      verticesB,
    );

    if (normalAndDepthA.depth < depth) {
      depth = normalAndDepthA.depth;
      normal = normalAndDepthA.normal;
    }
    final normalAndDepthB = CollisionUtil.getNormalAndDepth(
      verticesB,
      verticesA,
      insverted: true,
    );

    if (normalAndDepthB.depth < depth) {
      depth = normalAndDepthB.depth;
      normal = normalAndDepthB.normal;
    }

    // There is a separating axis.
    if (depth <= 0) return null;

    final Vector2d direction = a.absoluteCenter - b.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    return (normal: normal, depth: depth);
  }

  static ({Vector2d normal, double depth}) getNormalAndDepth(
    List<Vector2d> verticesA,
    List<Vector2d> verticesB, {
    bool insverted = false,
  }) {
    var normal = Vector2d.zero();
    double depth = double.maxFinite;
    for (int i = 0; i < verticesA.length; i++) {
      final Vector2d va = verticesA[i];
      final Vector2d vb = verticesA[(i + 1) % verticesA.length];

      final Vector2d edge = vb - va;
      Vector2d axis = Vector2d(-edge.y, edge.x);
      axis = axis.normalized();

      final pA = projectVertices(insverted ? verticesB : verticesA, axis);
      final pB = projectVertices(insverted ? verticesA : verticesB, axis);

      final double axisDepth = min(pB.max - pA.min, pA.max - pB.min);
      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }
    return (normal: normal, depth: depth);
  }

  static ({double min, double max}) projectVertices(
    List<Vector2d> vertices,
    Vector2d axis,
  ) {
    double min = double.maxFinite;
    double max = -double.maxFinite;
    for (var v in vertices) {
      final double proj = v.dot(axis);

      if (proj < min) {
        min = proj;
      }
      if (proj > max) {
        max = proj;
      }
    }
    return (min: min, max: max);
  }
}

/// Pair of objects with overlapping bounds (broad phase result).
/// Instances are pooled and reused between frames.
class CollidingPair<T> {
  CollidingPair(this._a, this._b);

  T _a;
  T _b;

  T get a => _a;
  T get b => _b;

  /// Sets the pair to contain [a] and [b] instead of what it previously
  /// contained.
  void set(T a, T b) {
    _a = a;
    _b = b;
  }
}

mixin CollisionObjectsMixin on QuadTreeCameraMixin {
  /// Bounciness: 0 - objects stick together, 1 - perfectly elastic.
  static const double _restitution = 0.8;

  /// Fraction of velocity lost per second (air friction).
  static const double _linearDamping = 0.5;

  /// Separation speed (px/s) per pixel of penetration.
  /// Overlapping objects are pushed apart with this speed.
  static const double _separationSpeed = 12;

  /// Limits the time step after long frames, so objects can't tunnel
  /// through bounds.
  static const double _maxDt = 0.05;

  final collisionObjects = <int, CollisionRectObject>{};
  final Paint _rectPaint = Paint()
    ..color = Colors.yellow.withAlpha(150)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;
  final Paint _collidingPaint = Paint()
    ..color = Colors.red.withAlpha(150)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  @override
  void mountQtCamera() {
    super.mountQtCamera();

    addSideBounds();
  }

  @override
  void unmountQtCamera() {
    super.unmountQtCamera();
    // Quadtree ids are recycled after clear, so drop all objects bound to them.
    collisionObjects.clear();
    _collidingObjectIds.clear();
    _collidingPairs.clear();
    _collidingPairsCount = 0;
  }

  // Bounds that will restrict the area where objects can move.
  void addSideBounds() {
    // Adding bounds to the screen box:
    const double boundWidth = 128;
    const double rectDimensions = 1024;
    final boundLeft = Rect.fromLTWH(
      cameraBoundary.center.dx - rectDimensions / 2 - boundWidth / 2,
      cameraBoundary.center.dy - rectDimensions,
      boundWidth,
      rectDimensions * 3,
    );
    final boundRight = Rect.fromLTWH(
      cameraBoundary.center.dx + rectDimensions / 2 - boundWidth / 2,
      cameraBoundary.center.dy - rectDimensions - boundWidth,
      boundWidth,
      rectDimensions * 3,
    );
    final boundTop = Rect.fromLTWH(
      cameraBoundary.center.dx - rectDimensions - boundWidth,
      cameraBoundary.center.dy - rectDimensions / 2 - boundWidth / 2,
      rectDimensions * 3,
      boundWidth,
    );
    final boundBottom = Rect.fromLTWH(
      cameraBoundary.center.dx - rectDimensions,
      cameraBoundary.center.dy + rectDimensions / 2 - boundWidth / 2,
      rectDimensions * 3,
      boundWidth,
    );

    quadTree.insert(boundLeft);
    quadTree.insert(boundRight);
    quadTree.insert(boundTop);
    quadTree.insert(boundBottom);
  }

  /// Draw points on the canvas.
  void drawCollisionObjects(Size size, Canvas canvas) {
    canvas.save();
    canvas.translate(-cameraBoundary.left, -cameraBoundary.top);
    for (final e in collisionObjects.values) {
      if (_collidingObjectIds.contains(e.id)) {
        canvas.drawRect(e.rect, _collidingPaint);
      } else {
        canvas.drawRect(e.rect, _rectPaint);
      }
    }
    canvas.restore();
  }

  void updateCollisionObjects(double delta) {
    final dt = min(delta / 1000, _maxDt);
    if (dt <= 0) return;

    // Syncing objects with the quadtree:
    quadTree.forEach((id, left, top, width, height) {
      final rect = Rect.fromLTWH(left, top, width, height);
      final obj = collisionObjects[id];
      if (obj == null) {
        collisionObjects[id] = CollisionRectObject(
          id: id,
          rect: rect,
          velocity: Vector2d.zero(),
        );
      } else {
        obj.rect = rect;
      }
      return true;
    });

    // Broad phase, finding pairs with overlapping bounds:
    _collidingPairsCount = 0;
    _collidingObjectIds.clear();
    for (final object in collisionObjects.values) {
      _findCollisionsWith(object);
    }

    // Narrow phase and collision resolution:
    for (var i = 0; i < _collidingPairsCount; i++) {
      _resolveCollision(_collidingPairs[i]);
    }

    // Moving objects depending on their velocities:
    final damping = exp(-_linearDamping * dt);
    for (final e in collisionObjects.values) {
      if (!e.canBeMoved) continue;
      e.velocity = e.velocity * damping;
      quadTree.move(
        e.id,
        e.rect.left + e.velocity.x * dt,
        e.rect.top + e.velocity.y * dt,
      );
    }
    needsPaintQt = true;
  }

  /// Pool of colliding pairs, only first [_collidingPairsCount] are actual.
  final _collidingPairs = <CollidingPair<CollisionRectObject>>[];
  int _collidingPairsCount = 0;
  final _collidingObjectIds = <int>{};

  void _findCollisionsWith(CollisionRectObject object) {
    final queryResult = quadTree.query(object.rect);
    for (final otherId in queryResult.ids) {
      // Overlapping is symmetric, so each pair is taken
      // only from the side of the object with the smaller id.
      if (otherId <= object.id) continue;
      final other = collisionObjects[otherId];
      if (other == null) continue;
      if (!object.canBeMoved && !other.canBeMoved) continue;
      if (_collidingPairsCount < _collidingPairs.length) {
        _collidingPairs[_collidingPairsCount].set(object, other);
      } else {
        _collidingPairs.add(CollidingPair(object, other));
      }
      _collidingPairsCount++;
    }
  }

  /// Impulse based collision resolution.
  void _resolveCollision(CollidingPair<CollisionRectObject> pair) {
    final a = pair.a;
    final b = pair.b;
    final colisionResult = CollisionUtil.intercectRects(a, b);
    if (colisionResult == null) return;
    _collidingObjectIds
      ..add(a.id)
      ..add(b.id);

    final inverseMassSum = a.inverseMass + b.inverseMass;
    if (inverseMassSum == 0) return;

    // The normal points from b to a, so positive velocity means separation.
    final normal = colisionResult.normal;
    final normalVelocity = (a.velocity - b.velocity).dot(normal);
    // Approaching objects bounce back.
    // Changing velocity depending on how deep objects intercet.
    final targetVelocity = max(
      -_restitution * normalVelocity,
      colisionResult.depth * _separationSpeed,
    );
    if (normalVelocity >= targetVelocity) return;
    final impulse =
        normal * ((targetVelocity - normalVelocity) / inverseMassSum);
    a.velocity = a.velocity + impulse * a.inverseMass;
    b.velocity = b.velocity - impulse * b.inverseMass;
  }
}

class QuadTreeCollisionPainter extends RePainterBase
    with QuadTreeCameraMixin, CollisionObjectsMixin {
  static const double _fieldExtent = 1152;

  final HardwareKeyboard _keyboardManager = HardwareKeyboard.instance;
  bool _spacebarPressed = false;

  @override
  bool get needsPaint => needsPaintQt;

  double _fitScale(Size size) => min(size.width, size.height) / _fieldExtent;

  @override
  void mount(RePaintBox box, PipelineOwner owner) {
    size = box.size;
    mountQtCamera();

    _keyboardManager.addHandler(onKeyboardEvent);
    _spacebarPressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      LogicalKeyboardKey.space,
    );
    needsPaintQt = true;
  }

  @override
  void unmount() {
    _keyboardManager.removeHandler(onKeyboardEvent);
    unmountQtCamera();
    _spacebarPressed = false;
    needsPaintQt = false;
  }

  bool onKeyboardEvent(KeyEvent event) {
    final bool? isKeyDown = switch (event) {
      KeyDownEvent _ => true,
      KeyRepeatEvent _ => true,
      KeyUpEvent _ => false,
      _ => null,
    };
    if (isKeyDown == null) return false; // Not a key press event.
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyW when isKeyDown:
      case LogicalKeyboardKey.arrowUp when isKeyDown:
        moveQtCamera(const Offset(0, -10));
      case LogicalKeyboardKey.keyS when isKeyDown:
      case LogicalKeyboardKey.arrowDown when isKeyDown:
        moveQtCamera(const Offset(0, 10));
      case LogicalKeyboardKey.keyA when isKeyDown:
      case LogicalKeyboardKey.arrowLeft when isKeyDown:
        moveQtCamera(const Offset(-10, 0));
      case LogicalKeyboardKey.keyD when isKeyDown:
      case LogicalKeyboardKey.arrowRight when isKeyDown:
        moveQtCamera(const Offset(10, 0));
      case LogicalKeyboardKey.space:
        _spacebarPressed = isKeyDown;
      default:
        return false; // Not a key we care about.
    }
    return true;
  }

  @override
  void onPointerEvent(PointerEvent event) {
    switch (event) {
      case final PointerHoverEvent hover:
        if (!_spacebarPressed) return;
        moveQtCamera(-hover.localDelta / _fitScale(size));
      case final PointerPanZoomUpdateEvent pan:
        moveQtCamera(pan.panDelta / _fitScale(size));
      case final PointerDownEvent down:
        // One rect per pointer down, dragging does not spawn more.
        _spawnRect(down.localPosition);
    }
  }

  void _spawnRect(Offset point) {
    // Calculate the dot offset from the camera.
    final cameraCenter = cameraBoundary.center;
    final scale = _fitScale(size);
    const double dimension = 64;
    final dot = Rect.fromCenter(
      center: Offset(
        (point.dx - size.width / 2) / scale + cameraCenter.dx,
        (point.dy - size.height / 2) / scale + cameraCenter.dy,
      ),
      width: dimension,
      height: dimension,
    );
    quadTree.insert(dot);
    needsPaintQt = true;
  }

  @override
  void update(RePaintBox box, Duration elapsed, double delta) {
    // If the size of the box has changed, update the camera too.
    if (box.size != size) {
      updateCameraBoundary(box.size);
    }
    updateCollisionObjects(delta);
  }

  final TextPainter _textPainter = TextPainter(
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
  );
  final Paint _bgPaint = Paint()..color = Colors.lightBlue;
  final Paint _statusBgPaint = Paint()..color = Colors.white54;

  int _spinnerIndex = 0;
  static const List<String> _spinnerSymbols = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  /// Draw current status.
  void _drawStatus(Size size, Canvas canvas) {
    _spinnerIndex++;
    final nbsp = String.fromCharCode(160);
    final status = StringBuffer()
      ..write(
        _spinnerSymbols[_spinnerIndex = _spinnerIndex % _spinnerSymbols.length],
      )
      ..write(' | ')
      ..write('World:')
      ..write(nbsp)
      ..write(quadTree.boundary.width.toStringAsFixed(0))
      ..write('x')
      ..write(quadTree.boundary.height.toStringAsFixed(0))
      ..write(' | ')
      ..write('Screen:')
      ..write(nbsp)
      ..write(size.width.toStringAsFixed(0))
      ..write('x')
      ..write(size.height.toStringAsFixed(0))
      ..write(' | ')
      ..write('Position:')
      ..write(nbsp)
      ..write(cameraBoundary.left.toStringAsFixed(0))
      ..write('x')
      ..write(cameraBoundary.top.toStringAsFixed(0))
      ..write(' | ')
      ..write('Points:')
      ..write(nbsp)
      ..write(collisionObjects.length)
      ..write('/')
      ..write(quadTree.length)
      ..write(' | ')
      ..write('Nodes:')
      ..write(nbsp)
      ..write(quadTree.nodes);
    _textPainter
      ..text = TextSpan(
        text: status.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'RobotoMono',
        ),
      )
      ..layout(maxWidth: size.width - 32);
    final textSize = _textPainter.size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8,
          size.height - textSize.height - 16 - 8,
          size.width - 16,
          textSize.height + 16,
        ),
        const Radius.circular(8),
      ),
      _statusBgPaint,
    );
    _textPainter.paint(canvas, Offset(16, size.height - textSize.height - 16));
  }

  final Paint _nodePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 0.1
    ..style = PaintingStyle.stroke;

  /// Draw the quadtree nodes on the canvas.
  void _drawQuadTree(Size size, Canvas canvas) {
    final cam = cameraBoundary;
    final scale = _fitScale(size);
    final visible = Rect.fromCenter(
      center: cam.center,
      width: size.width / scale,
      height: size.height / scale,
    );
    final queue = Queue<QuadTree$Node?>()..add(quadTree.root);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      if (node == null) continue;
      if (!node.boundary.overlaps(visible)) continue;
      if (node.subdivided) {
        // Parent node is subdivided, add children to the queue.
        queue
          ..add(node.northWest)
          ..add(node.northEast)
          ..add(node.southWest)
          ..add(node.southEast);
      } else {
        // Draw the leaf node.
        final nodeBounds = Rect.fromLTWH(
          node.boundary.left - cam.left,
          node.boundary.top - cam.top,
          node.boundary.width,
          node.boundary.height,
        );

        final k = 1.0 / (node.depth + 1);
        canvas.drawRect(
          nodeBounds,
          _nodePaint
            ..strokeWidth = k * 2
            ..color = Colors.white.withValues(alpha: 1 - k),
        );
      }
    }
  }

  @override
  void paint(RePaintBox box, PaintingContext context) {
    final size = box.size;
    final canvas = context.canvas;

    canvas.drawRect(Offset.zero & size, _bgPaint); // Draw background
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(_fitScale(size))
      ..translate(-size.width / 2, -size.height / 2)
      ..clipRect(
        Rect.fromCenter(
          center: quadTree.boundary.center - cameraBoundary.topLeft,
          width: _fieldExtent,
          height: _fieldExtent,
        ),
      );
    _drawQuadTree(size, canvas); // Draw quadtree nodes
    drawCollisionObjects(size, canvas); // Draw points
    canvas.restore();
    _drawStatus(size, canvas); // Draw status
    needsPaintQt = false; // Reset the flag.
  }
}
