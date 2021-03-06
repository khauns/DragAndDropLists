import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragAndDropList implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget header;

  /// The widget that is displayed at the bottom of the list.
  final Widget footer;

  /// The widget that is displayed to the left of the list.
  final Widget leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final List<DragAndDropItem> children = List<DragAndDropItem>();

  DragAndDropList(
      {List<DragAndDropItem> children,
      this.header,
      this.footer,
      this.leftSide,
      this.rightSide,
      this.contentsWhenEmpty,
      this.lastTarget,
      this.decoration,
      this.horizontalAlignment = MainAxisAlignment.start,
      this.verticalAlignment = CrossAxisAlignment.start}) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = List<Widget>();
    if (header != null) {
      contents.add(Flexible(child: header));
    }
    Widget intrinsicHeight = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: horizontalAlignment,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateDragAndDropListInnerContents(params),
      ),
    );
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = Container(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    contents.add(intrinsicHeight);

    if (footer != null) {
      contents.add(Flexible(child: footer));
    }

    return Container(
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding.horizontal,
      decoration: decoration ?? params.listDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: verticalAlignment,
        children: contents,
      ),
    );
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters params) {
    var contents = List<Widget>();
    if (leftSide != null) {
      contents.add(leftSide);
    }
    if (children != null && children.isNotEmpty) {
      List<Widget> allChildren = List<Widget>();
      children.forEach((element) => allChildren.add(DragAndDropItemWrapper(
            child: element,
            onPointerDown: params.onPointerDown,
            onPointerUp: params.onPointerUp,
            onPointerMove: params.onPointerMove,
            onItemReordered: params.onItemReordered,
            sizeAnimationDuration: params.itemSizeAnimationDuration,
            ghostOpacity: params.itemGhostOpacity,
            ghost: params.itemGhost,
            dragOnLongPress: params.dragOnLongPress,
            draggingWidth: params.draggingWidth,
            axis: params.axis,
            verticalAlignment: params.verticalAlignment,
          )));
      allChildren.add(DragAndDropItemTarget(
        parent: this,
        parameters: params,
        onReorderOrAdd: params.onItemDropOnLastTarget,
        child: lastTarget ??
            Container(
              height: 20,
            ),
      ));
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: verticalAlignment,
              mainAxisSize: MainAxisSize.max,
              children: allChildren,
            ),
          ),
        ),
      );
    } else {
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                contentsWhenEmpty ??
                    Text(
                      'Empty list',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                DragAndDropItemTarget(
                  parent: this,
                  parameters: params,
                  onReorderOrAdd: params.onItemDropOnLastTarget,
                  child: lastTarget ??
                      Container(
                        height: 20,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (rightSide != null) {
      contents.add(rightSide);
    }
    return contents;
  }
}
