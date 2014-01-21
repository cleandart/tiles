part of tiles_dom;

const _OPENMARK = "<";
const _CLOSEMARK = ">";
const _CLOSESIGN = "/";

class DomComponent extends Component {
  final String _tagName;
  final bool _pair;
  
  bool get pair => _pair;
  
  DomComponent(Props props, [needUpdateController, this._tagName, pair]): super(props, needUpdateController), this._pair = pair == null || pair {}
  
  String openMarkup() => "$_OPENMARK$_tagName${_pair ? "" : " $_CLOSESIGN"}$_CLOSEMARK";
  
  String closeMarkup() => _pair ? "$_OPENMARK$_CLOSESIGN$_tagName$_CLOSEMARK" : null;
  
}