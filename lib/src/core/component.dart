part of tiles;

class Component {

  /**
   * props of component
   */
  dynamic props;

  List<ComponentDescription> children;

  /**
   * stream controller used to signalize to node,
   * when component need to be udpated
   */
  final StreamController _needUpdateController;

  /**
   * Offer stream which will create event everytime, when it need to be updated (rendered).
   *
   * Stream use boolean data, which tells, if update should be done immediately
   */
  Stream<bool> get needUpdate => _needUpdateController.stream;

  /**
   * constructor, it create component with setted stream controller.
   *
   * If stream was not passed, it will create own stream controller
   */
  Component(this.props, [this.children]):
    this._needUpdateController = new StreamController<bool>() {}

  didMount() {}

  willReceiveProps(dynamic newProps) {}

  shouldUpdate(dynamic newProps, dynamic oldProps) => true;

  List<ComponentDescription> render() {}

  didUpdate() {}

  willUnmount() {}

  /**
   * redraw will add event to stream
   */
  redraw([bool now = false]) {
    _needUpdateController.add(now);
  }


}

