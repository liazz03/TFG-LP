import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Activity/events_category.dart';
import 'package:sqflite/sqflite.dart';
import '../../modules/Activity/event.dart';

class EventsDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addEvent(Event event) async {
    final db = await dbProvider;
    return await db.insert('events', event.toMap());
  }

  Future<int> updateEvent(Event event) async {
    final db = await dbProvider;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<List<Event>> getAllEvents() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> eventMaps = await db.query('events');
    List<Event> events = List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });

    //Update finished events
    List<Event> passedEvents = events.where((event) {
      return (event.timeslot.endDate != null && event.timeslot.endDate!.isBefore(DateTime.now())) ||
            (event.timeslot.endDate == null && event.timeslot.startDate.isBefore(DateTime.now()));
    }).toList();

    for (Event event in passedEvents) {
      if (event.state != EVENT_STATE.Finished) {
        event.state = EVENT_STATE.Finished;
        await updateEvent(event); 
      }
    }

    // return all events
    final List<Map<String, dynamic>> updatedEventMaps = await db.query('events');
    return List.generate(updatedEventMaps.length, (i) {
      return Event.fromMap(updatedEventMaps[i]);
    });
  }

  Future<String> getCategoryNameById(int categoryId) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'event_categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    if (maps.isNotEmpty) {
      return maps.first['category'] as String;
    } else {
      return ''; // category doesn't exists
    }
  }

  Future<Event?> getEventById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Event event = Event.fromMap(maps.first);

      // Optionally, fetch category name if needed
      if (event.categoryId != null) {
        String categoryName = await getCategoryNameById(event.categoryId!);
      }

      return event;
    } else {
      return null;
    }
  }


  Future<List<EventCategory>> getAllCategories() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('event_categories');

    return List.generate(maps.length, (i) {
      return EventCategory.fromMap(maps[i]);
    });
  }

    Future<int> addCategory(String categoryName) async {
    final db = await dbProvider;
    return await db.insert(
      'event_categories',
      {'category': categoryName},
      conflictAlgorithm: ConflictAlgorithm.replace, // To handle the unique constraint
    );
  }

  Future<int> deleteCategory(int categoryId) async {
    final db = await dbProvider;
    return await db.delete(
      'event_categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }
}
