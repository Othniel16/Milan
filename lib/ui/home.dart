import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milan/shared/barrier.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  ScrollController _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();

  List<Event> eventList = [];
  CalendarController _calendarController;

  bool showJumpToToday = false;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  maxRadius: 22.0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage: AssetImage(
                    'assets/icon/icon.png',
                  ),
                ),
                const Text(
                  'Days.',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
            onTap: _scrollToTop),
        actions: [
          showJumpToToday
              ? IconButton(
                  tooltip: 'Jump to Today',
                  color: Colors.black,
                  icon: Icon(Icons.calendar_today_outlined),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _calendarController.setSelectedDay(_selectedDate);
                      showJumpToToday = false;
                    });
                  })
              : SizedBox.shrink()
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
                  // calendar
                  _buildTableCalendar(),

                  // header
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 15.0),
                    child: Text(
                      eventList.isNotEmpty ? 'Timeline' : 'No events',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'Product Sans',
                        color: Color(0xff606060),
                      ),
                    ),
                  ),

                  // divider
                  Divider(),

                  // timeline
                  eventList.isNotEmpty
                      ? timelineModel(TimelinePosition.Left)
                      : Container(
                          child: Center(
                              child: Text(
                            'Tap ➕ to start adding events',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Product Sans',
                              color: Colors.grey,
                            ),
                          )),
                          height: MediaQuery.of(context).size.height / 2,
                        ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          onPressed: () async {
            bool result = await showCupertinoModalBottomSheet<bool>(
              context: context,
              builder: (context, scrollController) {
                return AddEvent();
              },
            );
            if (result == true) {
              showToast(message: '🎉 Event added 🎉', context: context);
              updateEventList();
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void updateEventList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Event>> eventListFuture = databaseHelper.getEvents();
      eventListFuture.then((events) {
        setState(() {
          this.eventList = events
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
      Column(
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
      iconBackground: Colors.transparent,
      icon: Icon(
        Icons.calendar_view_day,
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
    try {
      await databaseHelper.deleteEvent(event.id);
      showToast(context: context, message: '✨ Event removed from timeline ✨');
    } catch (error) {
      showToast(context: context, message: 'Oops, an error occurred');
    }
  }

  // Simple TableCalendar configuration
  Widget _buildTableCalendar() {
    return TableCalendar(
      initialCalendarFormat: CalendarFormat.week,
      calendarController: _calendarController,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.black,
        todayColor: Theme.of(context).primaryColor,
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (DateTime date, List events, List holidays) {
        if (date.day != _selectedDate.day) {
          setState(() {
            _selectedDate = date;
            showJumpToToday = true;
          });
        } else {
          setState(() {
            showJumpToToday = false;
          });
        }
      },
    );
  }
}
