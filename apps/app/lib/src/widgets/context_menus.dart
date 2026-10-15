import 'package:flutter/material.dart';

// Flutter's own menus, as the web app turns the browser's off. Their buttons
// take no focus: with semantics on the web, a click on one would move the
// focus, clearing the selection before its tap acts on it.

Widget textFieldMenu(BuildContext context, EditableTextState state) =>
    ExcludeFocus(
      child: AdaptiveTextSelectionToolbar.editableText(
        editableTextState: state,
      ),
    );

Widget selectionMenu(BuildContext context, SelectableRegionState state) =>
    ExcludeFocus(
      child: AdaptiveTextSelectionToolbar.selectableRegion(
        selectableRegionState: state,
      ),
    );
