import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:schedules/schedules.dart';
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

    // Optionally fetch category name for each event
    for (var event in events) {
      if (event.categoryId != null) {
        String categoryName = await getCategoryNameById(event.categoryId!);
        // Do something with categoryName, like adding it to the Event object if it has a field for it
      }
    }

    return events;
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
        // Here, you could add the category name to the Event object if it has a property for it
        // For example: event.categoryName = categoryName;
      }

      return event;
    } else {
      return null;
    }
  }
}
