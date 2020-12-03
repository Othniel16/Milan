import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milan/shared/barrier.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TimeOfDay _time = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  String title = '';
  String description = '';
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime startDate = DateTime.now();
  Widget divider = Container(
    margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
    child: Divider(),
  );

  TextStyle _style = TextStyle(fontFamily: 'Product Sans', color: Colors.grey);

  List<String> _actions = [
    'Shower',
    'Breakfast',
    'Lunch',
    'Nap',
    'Supper',
    'Chores',
    'Bedtime',
    'Movie',
    'Code',
    'Game',
    'Wake up',
  ];

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int daysSinceFirstLaunch = DateTime.now().difference(startDate).inDays;
    _actions.sort();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Add event',
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.black),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: GestureDetector(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.clear,
              color: Colors.black,
            ),
          ),
          onTap: () => Navigator.pop(context, false),
        ),
        actions: [
          title.isNotEmpty
              ? FlatButton(
                  onPressed: _save,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      color: Colors.blue,
                    ),
                  ))
              : Container(),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // title
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: _style,
                ),
                SizedBox(height: 7.0),
                Row(
                  children: [
                    // title field
                    Expanded(
                        child: TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        hintText: 'Event title',
                      ),
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: DropDown(
                        hint: Text('Quick pick'),
                        items: _actions,
                        onChanged: (value) {
                          setState(() {
                            title = value;
                            titleController.text = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          divider,

          // description
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: _style,
                ),
                SizedBox(height: 7.0),
                // description field
                TextField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: null,
                  maxLines: null,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    hintText: 'Description (optional)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                ),
              ],
            ),
          ),

          divider,

          // time
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time',
                  style: _style,
                ),
                SizedBox(
                  height: 7.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _time.format(context),
                        style: Theme.of(context).textTheme.headline4.copyWith(
                              fontFamily: 'Product Sans',
                            ),
                      ),
                    ),

                    // change time
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      color: Colors.teal,
                      onPressed: () {
                        Navigator.of(context).push(
                          showPicker(
                            context: context,
                            value: _time,
                            onChange: onTimeChanged,
                          ),
                        );
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          divider,

          // date
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: _style,
                ),
                SizedBox(
                  height: 7.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat.yMMMd().format(_selectedDate),
                        style: Theme.of(context).textTheme.headline4.copyWith(
                              fontFamily: 'Product Sans',
                            ),
                      ),
                    ),

                    // choose date
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      color: Colors.teal,
                      onPressed: () {
                        _showDatePicker(daysSinceFirstLaunch);
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Save data to database
  void _save() async {
    String date = DateFormat.yMMMd().format(_selectedDate);

    Event event =
        Event(title.trim(), date, _time.format(context), description.trim());

    int result;

    result = await helper.insertEvent(event);

    if (result != 0) {
      // Success
      Navigator.pop(context, true);
    } else {
      // Failure
      Navigator.pop(context, false);
      showToast(context: context, message: 'Event not added');
    }
  }

  void _showDatePicker(int daysSinceFirstLaunch) {
    AlertDialog alertDialog = AlertDialog(
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
      ],
      content: Container(
        width: double.maxFinite,
        child: DatePicker(
          DateTime.now(),
          height: 85.0,
          initialSelectedDate: DateTime.now(),
          daysCount: 22 + (21 * ((daysSinceFirstLaunch / 21) ~/ 21)),
          selectionColor: Colors.black,
          selectedTextColor: Colors.white,
          onDateChange: (date) {
            // New date selected
            setState(() {
              _selectedDate = date;
            });
          },
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
