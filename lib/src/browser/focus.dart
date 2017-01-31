part of tiles_browser;

html.Element _toBeFocused;

/**
 * Reset focus before any re-rendering.
 */
_resetFocus() {
  _toBeFocused = null;
}

/**
 * if any element should be focused focus it
 */
_focus() {
  if (_toBeFocused != null) {
    _toBeFocused.focus();
    _toBeFocused = null;
  }
}