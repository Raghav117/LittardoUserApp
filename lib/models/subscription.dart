class Subription {
  String _id;
  String _title;
  String _description;
  String _amount;
  String _type;
  String _created_at;
  String _updated_at;

  Subription(this._id, this._title, this._description, this._amount,this._type, this._created_at,
      this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }


  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
String get type => _type;

  set type(String value) {
    _type = value;
  }
}
