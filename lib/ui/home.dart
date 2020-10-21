import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:milan/shared/barrier.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  ScrollController _scrollController = new ScrollController();
  DateTime _selectedDate = DateTime.now();
  List<Event> eventList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: GestureDetector(
            child: const Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Product Sans',
              ),
            ),
            onTap: _scrollToTop),
        actions: [
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.add),
            onPressed: () async {
              bool result = await showCupertinoModalBottomSheet<bool>(
                context: context,
                builder: (context, scrollController) {
                  return AddEvent();
                },
              );
              if (result == true) {
                updateEventList();
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: databaseHelper.getEvents(),
          initialData: List(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              updateEventList();
              return ListView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30.0),
                children: [
                  // date selector
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: DatePicker(
                      DateTime(2020, 10, 19),
                      daysCount: 21,
                      width: 60,
                      height: 80,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Color(0xff606060),
                      selectedTextColor: Colors.white,
                      onDateChange: (date) {
                        // New date selected
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ),

                  // overview
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 15.0),
                    child: Text(
                      eventList.isNotEmpty ? 'Overview' : 'No activity',
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 30.0,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // divider
                  Divider(),

                  // timeline
                  timelineModel(TimelinePosition.Left),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  void updateEventList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Event>> eventListFuture = databaseHelper.getEvents();
      eventListFuture.then((eventList) {
        setState(() {
          this.eventList = eventList
              .where((event) =>
                  event.date == DateFormat.yMMMd().format(_selectedDate))
              .toList();
        });
      });
    });
  }

  timelineModel(TimelinePosition position) => Timeline.builder(
        reverse: true,
        itemBuilder: centerTimelineBuilder,
        itemCount: eventList.length,
        shrinkWrap: true,
        position: position,
        lineColor: Color(0xff91d9c9),
      );

  TimelineModel centerTimelineBuilder(BuildContext context, int index) {
    Event event = eventList[index];
    return TimelineModel(
      Container(
        margin: const EdgeInsets.only(top: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30.0,
            ),
            Text(
              event.time,
              style: TextStyle(fontFamily: 'Product Sans'),
            ),
            FocusedMenuHolder(
              child: Card(
                color: Color(0xff91dea7),
                elevation: 10.0,
                shadowColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        event.title,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      event.description.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                event.description,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              onPressed: () {},
              menuWidth: MediaQuery.of(context).size.width * 0.50,
              blurSize: 8.0,
              menuItemExtent: 45,
              menuBoxDecoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              duration: Duration(milliseconds: 100),
              animateMenuItems: true,
              blurBackgroundColor: Colors.black54,
              menuOffset:
                  10.0, // Offset value to show menuItem from the selected item
              bottomOffsetHeight:
                  80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
              menuItems: <FocusedMenuItem>[
                FocusedMenuItem(
                    title: Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    trailingIcon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      _deleteEvent(context, event);
                    }),
              ],
            ),
          ],
        ),
      ),
      iconBackground: Colors.transparent,
      icon: Icon(
        Icons.calendar_view_day_outlined,
        color: Colors.black,
      ),
      position: index % 2 == 0
          ? TimelineItemPosition.right
          : TimelineItemPosition.left,
      isFirst: index == 0,
      isLast: index == eventList.length,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _deleteEvent(BuildContext context, Event event) async {
    int result = await databaseHelper.deleteEvent(event.id);
    if (result != 0) {
      showToast(context: context, message: '✨ Event removed from timeline ✨');
      updateEventList();
    }
  }
}
