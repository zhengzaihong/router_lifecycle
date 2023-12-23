// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math' show max, min;

import 'dart:async' show Timer;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';


/// A [VisibilityDetector] widget fires a specified callback when the widget
/// changes visibility.
///
/// Callbacks are not fired immediately on visibility changes.  Instead,
/// callbacks are deferred and coalesced such that the callback for each
/// [VisibilityDetector] will be invoked at most once per
/// [VisibilityDetectorController.updateInterval] (unless forced by
/// [VisibilityDetectorController.notifyNow]).  Callbacks for *all*
/// [VisibilityDetector] widgets are fired together synchronously between
/// frames.
class VisibilityDetector extends SingleChildRenderObjectWidget {
  /// Constructor.
  ///
  /// `key` is required to properly identify this widget; it must be unique
  /// among all [VisibilityDetector] and [SliverVisibilityDetector] widgets.
  ///
  /// `onVisibilityChanged` may be `null` to disable this [VisibilityDetector].
  const VisibilityDetector({
    required Key key,
    required Widget child,
    required this.onVisibilityChanged,
  })  : assert(key != null),
        assert(child != null),
        super(key: key, child: child);

  /// The callback to invoke when this widget's visibility changes.
  final VisibilityChangedCallback? onVisibilityChanged;

  /// See [RenderObjectWidget.createRenderObject].
  @override
  RenderVisibilityDetector createRenderObject(BuildContext context) {
    return RenderVisibilityDetector(
      key: key!,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  /// See [RenderObjectWidget.updateRenderObject].
  @override
  void updateRenderObject(
      BuildContext context, RenderVisibilityDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onVisibilityChanged = onVisibilityChanged;
  }
}

class SliverVisibilityDetector extends SingleChildRenderObjectWidget {
  /// Constructor.
  ///
  /// `key` is required to properly identify this widget; it must be unique
  /// among all [VisibilityDetector] and [SliverVisibilityDetector] widgets.
  ///
  /// `onVisibilityChanged` may be `null` to disable this
  /// [SliverVisibilityDetector].
  const SliverVisibilityDetector({
    required Key key,
    required Widget sliver,
    required this.onVisibilityChanged,
  })  : assert(key != null),
        assert(sliver != null),
        super(key: key, child: sliver);

  /// The callback to invoke when this widget's visibility changes.
  final VisibilityChangedCallback? onVisibilityChanged;

  /// See [RenderObjectWidget.createRenderObject].
  @override
  RenderSliverVisibilityDetector createRenderObject(BuildContext context) {
    return RenderSliverVisibilityDetector(
      key: key!,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  /// See [RenderObjectWidget.updateRenderObject].
  @override
  void updateRenderObject(
      BuildContext context, RenderSliverVisibilityDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onVisibilityChanged = onVisibilityChanged;
  }
}

typedef VisibilityChangedCallback = void Function(VisibilityInfo info);

/// Data passed to the [VisibilityDetector.onVisibilityChanged] callback.
@immutable
class VisibilityInfo {
  /// Constructor.
  ///
  /// `key` corresponds to the [Key] used to construct the corresponding
  /// [VisibilityDetector] widget.  Must not be null.
  ///
  /// If `size` or `visibleBounds` are omitted or null, the [VisibilityInfo]
  /// will be initialized to [Offset.zero] or [Rect.zero] respectively.  This
  /// will indicate that the corresponding widget is competely hidden.
  const VisibilityInfo({required this.key, Size? size, Rect? visibleBounds})
      : assert(key != null),
        size = size ?? Size.zero,
        visibleBounds = visibleBounds ?? Rect.zero;

  /// Constructs a [VisibilityInfo] from widget bounds and a corresponding
  /// clipping rectangle.
  ///
  /// [widgetBounds] and [clipRect] are expected to be in the same coordinate
  /// system.
  factory VisibilityInfo.fromRects({
    required Key key,
    required Rect widgetBounds,
    required Rect clipRect,
  }) {
    assert(widgetBounds != null);
    assert(clipRect != null);

    // Compute the intersection in the widget's local coordinates.
    final visibleBounds = widgetBounds.overlaps(clipRect)
        ? widgetBounds.intersect(clipRect).shift(-widgetBounds.topLeft)
        : Rect.zero;

    return VisibilityInfo(
        key: key, size: widgetBounds.size, visibleBounds: visibleBounds);
  }

  /// The key for the corresponding [VisibilityDetector] widget.
  final Key key;

  /// The size of the widget.
  final Size size;

  /// The visible portion of the widget, in the widget's local coordinates.
  ///
  /// The bounds are reported using the widget's local coordinates to avoid
  /// expectations for the [VisibilityChangedCallback] to fire if the widget's
  /// position changes but retains the same visibility.
  final Rect visibleBounds;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  double get visibleFraction {
    final visibleArea = _area(visibleBounds.size);
    final maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      // Avoid division-by-zero.
      return 0;
    }

    var visibleFraction = visibleArea / maxVisibleArea;

    if (_floatNear(visibleFraction, 0)) {
      visibleFraction = 0;
    } else if (_floatNear(visibleFraction, 1)) {
      // The inexact nature of floating-point arithmetic means that sometimes
      // the visible area might never equal the maximum area (or could even
      // be slightly larger than the maximum).  Snap to the maximum.
      visibleFraction = 1;
    }

    assert(visibleFraction >= 0);
    assert(visibleFraction <= 1);
    return visibleFraction;
  }

  /// Returns true if the specified [VisibilityInfo] object has equivalent
  /// visibility to this one.
  bool matchesVisibility(VisibilityInfo info) {
    // We don't override `operator ==` so that object equality can be separate
    // from whether two [VisibilityInfo] objects are sufficiently similar
    // that we don't need to fire callbacks for both.  This could be pertinent
    // if other properties are added.
    assert(info != null);
    return size == info.size && visibleBounds == info.visibleBounds;
  }

  @override
  String toString() {
    return 'VisibilityInfo(size: $size visibleBounds: $visibleBounds)';
  }
}

/// The tolerance used to determine whether two floating-point values are
/// approximately equal.
const _kDefaultTolerance = 0.01;

/// Computes the area of a rectangle of the specified dimensions.
double _area(Size size) {
  assert(size != null);
  assert(size.width >= 0);
  assert(size.height >= 0);
  return size.width * size.height;
}

/// Returns whether two floating-point values are approximately equal.
bool _floatNear(double f1, double f2) {
  final absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance ||
      (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}


/// The [RenderObject] corresponding to the [VisibilityDetector] widget.
///
/// [RenderVisibilityDetector] is a bridge between [VisibilityDetector] and
/// [VisibilityDetectorLayer].
class RenderVisibilityDetector extends RenderProxyBox {
  /// Constructor.  See the corresponding properties for parameter details.
  RenderVisibilityDetector({
    RenderBox? child,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  })  : assert(key != null),
        _onVisibilityChanged = onVisibilityChanged,
        super(child);

  /// The key for the corresponding [VisibilityDetector] widget.
  final Key key;

  VisibilityChangedCallback? _onVisibilityChanged;

  /// See [VisibilityDetector.onVisibilityChanged].
  VisibilityChangedCallback? get onVisibilityChanged => _onVisibilityChanged;

  /// Used by [VisibilityDetector.updateRenderObject].
  set onVisibilityChanged(VisibilityChangedCallback? value) {
    _onVisibilityChanged = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  // See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => onVisibilityChanged != null;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged == null) {
      // No need to create a [VisibilityDetectorLayer].  However, in case one
      // already exists, remove all cached data for it so that we won't fire
      // visibility callbacks when the layer is removed.
      VisibilityDetectorLayer.forget(key);
      super.paint(context, offset);
      return;
    }

    final layer = VisibilityDetectorLayer(
        key: key,
        widgetOffset: Offset.zero,
        widgetSize: semanticBounds.size,
        paintOffset: offset,
        onVisibilityChanged: onVisibilityChanged!);
    context.pushLayer(layer, super.paint, offset);
  }
}


/// Returns a sequence containing the specified [Layer] and all of its
/// ancestors.  The returned sequence is in [parent, child] order.
Iterable<Layer> _getLayerChain(Layer start) {
  final layerChain = <Layer>[];
  for (Layer? layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

/// Returns the accumulated transform from the specified sequence of [Layer]s.
/// The sequence must be in [parent, child] order.  The sequence must not be
/// null.
Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
  assert(layerChain != null);

  final transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    var parent = layerChain.first;
    for (final child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}

/// Converts a [Rect] in local coordinates of the specified [Layer] to a new
/// [Rect] in global coordinates.
Rect _localRectToGlobal(Layer layer, Rect localRect) {
  final layerChain = _getLayerChain(layer);

  // Skip the root layer which transforms from logical pixels to physical
  // device pixels.
  assert(layerChain.isNotEmpty);
  assert(layerChain.first is TransformLayer);
  final transform = _accumulateTransforms(layerChain.skip(1));
  return MatrixUtils.transformRect(transform, localRect);
}


/// The [Layer] corresponding to a [VisibilityDetector] widget.
///
/// We use a [Layer] because we can directly determine visibility by virtue of
/// being added to the [SceneBuilder].
class VisibilityDetectorLayer extends ContainerLayer {
  /// Constructor.  See the corresponding properties for parameter details.
  VisibilityDetectorLayer(
      {required this.key,
        required this.widgetOffset,
        required this.widgetSize,
        required this.paintOffset,
        required this.onVisibilityChanged})
      : assert(key != null),
        assert(paintOffset != null),
        assert(widgetSize != null),
        assert(onVisibilityChanged != null);

  /// Timer used by [_scheduleUpdate].
  static Timer? _timer;

  /// Keeps track of [VisibilityDetectorLayer] objects that have been recently
  /// updated and that might need to report visibility changes.
  ///
  /// Additionally maps [VisibilityDetector] keys to the most recently added
  /// [VisibilityDetectorLayer] that corresponds to it; this mapping is
  /// necessary in case a layout change causes a new layer to be instantiated
  /// for an existing key.
  static final _updated = <Key, VisibilityDetectorLayer>{};

  /// Keeps track of the last known visibility state of a [VisibilityDetector].
  ///
  /// This is used to suppress extraneous callbacks when visibility hasn't
  /// changed.  Stores entries only for visible [VisibilityDetector] objects;
  /// entries for non-visible ones are actively removed.  See [_fireCallback].
  static final _lastVisibility = <Key, VisibilityInfo>{};

  /// Keeps track of the last known bounds of a [VisibilityDetector], in global
  /// coordinates.
  static Map<Key, Rect> get widgetBounds => _lastBounds;
  static final _lastBounds = <Key, Rect>{};

  /// The key for the corresponding [VisibilityDetector] widget.
  final Key key;

  /// Offset to the start of the widget, in local coordinates.
  ///
  /// This is zero for box widgets. For sliver widget, this offset points to
  /// the start of the widget which may be outside the viewport.
  final Offset widgetOffset;

  /// The size of the corresponding [VisibilityDetector] widget.
  final Size widgetSize;

  /// The offset supplied to [RenderVisibilityDetector.paint] method.
  final Offset paintOffset;

  /// See [VisibilityDetector.onVisibilityChanged].
  ///
  /// Do not invoke this directly; call [_fireCallback] instead.
  final VisibilityChangedCallback onVisibilityChanged;

  /// Computes the bounds for the corresponding [VisibilityDetector] widget, in
  /// global coordinates.
  Rect _computeWidgetBounds() {
    return _localRectToGlobal(this, paintOffset + widgetOffset & widgetSize);
  }

  /// Computes the accumulated clipping bounds, in global coordinates.
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    var clipRect = Offset.zero & RendererBinding.instance!.renderView.size;

    var parentLayer = parent;
    while (parentLayer != null) {
      Rect? curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect!.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath!.getBounds();
      }

      if (curClipRect != null) {
        // This is O(n^2) WRT the depth of the tree since `_localRectToGlobal`
        // also walks up the tree.  In practice there probably will be a small
        // number of clipping layers in the chain, so it might not be a problem.
        // Alternatively we could cache transformations and clipping rectangles.
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  /// Schedules a timer to invoke the visibility callbacks.  The timer is used
  /// to throttle and coalesce updates.
  void _scheduleUpdate() {
    final isFirstUpdate = _updated.isEmpty;
    _updated[key] = this;

    final updateInterval = VisibilityDetectorController.instance.updateInterval;
    if (updateInterval == Duration.zero) {
      // Even with [Duration.zero], we still want to defer callbacks to the end
      // of the frame so that they're processed from a consistent state.  This
      // also ensures that they don't mutate the widget tree while we're in the
      // middle of a frame.
      if (isFirstUpdate) {
        // We're about to render a frame, so a post-frame callback is guaranteed
        // to fire and will give us the better immediacy than `scheduleTask<T>`.
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer!.isActive);
    }
  }

  /// [Timer] callback.  Defers visibility callbacks to execute after the next
  /// frame.
  static void _handleTimer() {
    _timer = null;

    // Ensure that work is done between frames so that calculations are
    // performed from a consistent state.  We use `scheduleTask<T>` here instead
    // of `addPostFrameCallback` or `scheduleFrameCallback` so that work will
    // be done even if a new frame isn't scheduled and without unnecessarily
    // scheduling a new frame.
    SchedulerBinding.instance!
        .scheduleTask<void>(_processCallbacks, Priority.touch);
  }

  /// See [VisibilityDetectorController.notifyNow].
  static void notifyNow() {
    _timer?.cancel();
    _timer = null;
    _processCallbacks();
  }

  /// Removes entries corresponding to the specified [Key] from our internal
  /// caches.
  static void forget(Key key) {
    _updated.remove(key);
    _lastVisibility.remove(key);
    _lastBounds.remove(key);

    if (_updated.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Executes visibility callbacks for all updated [VisibilityDetectorLayer]
  /// instances.
  static void _processCallbacks() {
    for (final layer in _updated.values) {
      if (!layer.attached) {
        layer._fireCallback(VisibilityInfo(
            key: layer.key, size: _lastVisibility[layer.key]?.size));
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();
      _lastBounds[layer.key] = widgetBounds;

      final info = VisibilityInfo.fromRects(
          key: layer.key,
          widgetBounds: widgetBounds,
          clipRect: layer._computeClipRect());
      layer._fireCallback(info);
    }
    _updated.clear();
  }

  /// Invokes the visibility callback if [VisibilityInfo] hasn't meaningfully
  /// changed since the last time we invoked it.
  void _fireCallback(VisibilityInfo info) {
    assert(info != null);

    final oldInfo = _lastVisibility[key];
    final visible = !info.visibleBounds.isEmpty;

    if (oldInfo == null) {
      if (!visible) {
        return;
      }
    } else if (info.matchesVisibility(oldInfo)) {
      return;
    }

    if (visible) {
      _lastVisibility[key] = info;
    } else {
      // Track only visible items so that the maps don't grow unbounded.
      _lastVisibility.remove(key);
      _lastBounds.remove(key);
    }

    onVisibilityChanged(info);
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    // TODO(goderbauer): Remove unused layerOffset parameter once
    //     https://github.com/flutter/flutter/pull/91753 is in stable.
    assert(layerOffset == Offset.zero);
    _scheduleUpdate();
    super.addToScene(builder);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    _scheduleUpdate();
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    _scheduleUpdate();
  }

  /// See [Diagnosticable.debugFillProperties].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<Key>('key', key))
      ..add(DiagnosticsProperty<Rect>('widgetRect', _computeWidgetBounds()))
      ..add(DiagnosticsProperty<Rect>('clipRect', _computeClipRect()));
  }
}


/// The [RenderObject] corresponding to the [SliverVisibilityDetector] widget.
///
/// [RenderSliverVisibilityDetector] is a bridge between
/// [SliverVisibilityDetector] and [VisibilityDetectorLayer].
class RenderSliverVisibilityDetector extends RenderProxySliver {
  /// Constructor.  See the corresponding properties for parameter details.
  RenderSliverVisibilityDetector({
    RenderSliver? sliver,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  })  : _onVisibilityChanged = onVisibilityChanged,
        super(sliver);

  /// The key for the corresponding [VisibilityDetector] widget.
  final Key key;

  VisibilityChangedCallback? _onVisibilityChanged;

  /// See [VisibilityDetector.onVisibilityChanged].
  VisibilityChangedCallback? get onVisibilityChanged => _onVisibilityChanged;

  /// Used by [VisibilityDetector.updateRenderObject].
  set onVisibilityChanged(VisibilityChangedCallback? value) {
    _onVisibilityChanged = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  // See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => onVisibilityChanged != null;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged == null) {
      // No need to create a [VisibilityDetectorLayer].  However, in case one
      // already exists, remove all cached data for it so that we won't fire
      // visibility callbacks when the layer is removed.
      VisibilityDetectorLayer.forget(key);
      super.paint(context, offset);
      return;
    }

    Size widgetSize;
    Offset widgetOffset;
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.down:
        widgetOffset = Offset(0, -constraints.scrollOffset);
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.up:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(0, min(startOffset, 0));
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.right:
        widgetOffset = Offset(-constraints.scrollOffset, 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
      case AxisDirection.left:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(min(startOffset, 0), 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
    }

    final layer = VisibilityDetectorLayer(
        key: key,
        widgetOffset: widgetOffset,
        widgetSize: widgetSize,
        paintOffset: offset,
        onVisibilityChanged: onVisibilityChanged!);
    context.pushLayer(layer, super.paint, offset);
  }
}



/// A [VisibilityDetectorController] is a singleton object that can perform
/// actions and change configuration for all [VisibilityDetector] widgets.
class VisibilityDetectorController {
  static final _instance = VisibilityDetectorController();
  static VisibilityDetectorController get instance => _instance;

  /// The minimum amount of time to wait between firing batches of visibility
  /// callbacks.
  ///
  /// If set to [Duration.zero], callbacks instead will fire at the end of every
  /// frame.  This is useful for automated tests.
  ///
  /// Changing [updateInterval] will not affect any pending callbacks.  Clients
  /// should call [notifyNow] explicitly to flush them if desired.
  Duration updateInterval = const Duration(milliseconds: 500);

  /// Forces firing all pending visibility callbacks immediately.
  ///
  /// This might be desirable just prior to tearing down the widget tree (such
  /// as when switching views or when exiting the application).
  void notifyNow() => VisibilityDetectorLayer.notifyNow();

  /// Forgets any pending visibility callbacks for the [VisibilityDetector] with
  /// the given [key].
  ///
  /// If the widget gets attached/detached, the callback will be rescheduled.
  ///
  /// This method can be used to cancel timers after the [VisibilityDetector]
  /// has been detached to avoid pending timers in tests.
  void forget(Key key) => VisibilityDetectorLayer.forget(key);

  /// Returns the last known bounds for the [VisibilityDetector] with the given
  /// [key] in global coordinates.
  ///
  /// Returns null if the specified [VisibilityDetector] is not visible or is
  /// not found.
  Rect? widgetBoundsFor(Key key) => VisibilityDetectorLayer.widgetBounds[key];
}
