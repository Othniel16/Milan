class Event {
  int _id;
  String _title;
  String _description;
  String _date;
  String _time;

  Event(this._title, this._date, this._time, [this._description]);

  Event.withId(this._id, this._title, this._date, this._time,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  String get time => _time;

  String get date => _date;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set time(String newTime) {
    this._time = newTime;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Convert an Event object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['time'] = _time;
    map['date'] = _date;

    return map;
  }

  // Extract an Event object from a Map object
  Event.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._time = map['time'];
    this._date = map['date'];
  }
}
