import 'dart:async';
import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getEventsByCity(String city);
  Future<List<Event>> getEventsByCategory(EventCategory category);
}

class MockEventRepository implements EventRepository {
  static final DateTime _baseDate = DateTime.now();

  static final List<Event> _mockEvents = [
    Event(
      id: 'evt-1',
      title: 'Beyoncé',
      description: 'Renaissance World Open Air Experience live performance set.',
      category: EventCategory.concerts,
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 1, 19, 30),
      venueName: 'Accor Arena, Berlin',
      city: 'Berlin',
      isFree: true,
      organizer: 'Berlin Live Nights',
    ),
    Event(
      id: 'evt-2',
      title: 'Billie Eilish',
      description: 'Hit Me Hard and Soft Acoustic Secret Garden Show.',
      category: EventCategory.concerts,
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 2, 20, 00),
      venueName: 'Tempelhof Field, Berlin',
      city: 'Berlin',
      isFree: true,
      organizer: 'Indie Sound DE',
    ),
    Event(
      id: 'evt-3',
      title: 'The Weeknd',
      description: 'After Hours Open Air Light & Sound Spectacle.',
      category: EventCategory.festivals,
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 3, 21, 00),
      venueName: 'Mauerpark Amphitheater',
      city: 'Berlin',
      isFree: true,
      organizer: 'Mauerpark Beats',
    ),
    Event(
      id: 'evt-4',
      title: 'Dua Lipa',
      description: 'Radical Optimism Pop-Up Beach Session.',
      category: EventCategory.concerts,
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 4, 18, 30),
      venueName: 'Eisbach Promenade, Munich',
      city: 'Munich',
      isFree: true,
      organizer: 'Munich Wave Sessions',
    ),
    Event(
      id: 'evt-5',
      title: 'Munich Digital Light Expo',
      description: 'Interactive 3D Projection Mapping & Light Installation.',
      category: EventCategory.exhibitions,
      imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 5, 17, 00),
      venueName: 'Kunstareal Munich',
      city: 'Munich',
      isFree: true,
      organizer: 'Munich Art Collective',
    ),
    Event(
      id: 'evt-6',
      title: 'Streetball 3v3 Jam',
      description: 'Urban Hoops Tournament & Freestyle DJ Battles.',
      category: EventCategory.sports,
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 6, 15, 00),
      venueName: 'St. Pauli Courts, Hamburg',
      city: 'Hamburg',
      isFree: true,
      organizer: 'Urban Sports DE',
    ),
    Event(
      id: 'evt-7',
      title: 'Elbe Waterfront Food & Vinyl Fest',
      description: 'Street Food Pop-Ups & Rare Record Listening Booths.',
      category: EventCategory.food,
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 7, 12, 00),
      venueName: 'St. Pauli Piers, Hamburg',
      city: 'Hamburg',
      isFree: true,
      organizer: 'Hamburg Foodies',
    ),
    Event(
      id: 'evt-8',
      title: 'Open Air Cinema Under Stars',
      description: 'Indie Short Film Screenings with Director Q&As.',
      category: EventCategory.film,
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 8, 20, 30),
      venueName: 'Rheinpark Köln',
      city: 'Cologne',
      isFree: true,
      organizer: 'Cologne Freiluft Kino',
    ),
    Event(
      id: 'evt-9',
      title: 'Rhine Promenade Sunset Yoga',
      description: 'Community Group Flow and Meditation Session.',
      category: EventCategory.community,
      imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 9, 09, 00),
      venueName: 'Rhine River Walk, Cologne',
      city: 'Cologne',
      isFree: true,
      organizer: 'Köln Wellness Club',
    ),
    Event(
      id: 'evt-10',
      title: 'Frankfurt Tech & AI Open Night',
      description: 'Interactive Hack Showcase, Talks & Drinks.',
      category: EventCategory.community,
      imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 10, 18, 00),
      venueName: 'TechQuartier, Frankfurt',
      city: 'Frankfurt',
      isFree: true,
      organizer: 'Frankfurt Devs',
    ),
    Event(
      id: 'evt-11',
      title: 'Leipzig Mural & Street Art Jam',
      description: 'Live Mural Creations & Urban Art Market.',
      category: EventCategory.exhibitions,
      imageUrl: 'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?auto=format&fit=crop&w=600&q=70',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 11, 14, 00),
      venueName: 'Baumwollspinnerei, Leipzig',
      city: 'Leipzig',
      isFree: true,
      organizer: 'Leipzig Urban Art',
    ),
    Event(
      id: 'evt-12',
      title: 'Midnight Techno Underground',
      description: 'Free Admission Before 0:00. Ambient Soundscapes & Visuals.',
      category: EventCategory.nightlife,
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime(_baseDate.year, _baseDate.month, _baseDate.day + 12, 23, 00),
      venueName: 'Karl-Liebknecht Club, Leipzig',
      city: 'Leipzig',
      isFree: true,
      organizer: 'Leipzig Sound Lab',
    ),
  ];

  @override
  Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_mockEvents);
  }

  @override
  Future<List<Event>> getEventsByCity(String city) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (city == 'All Cities' || city.isEmpty) return getEvents();
    return _mockEvents.where((e) => e.city.toLowerCase() == city.toLowerCase()).toList();
  }

  @override
  Future<List<Event>> getEventsByCategory(EventCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (category == EventCategory.all) return getEvents();
    return _mockEvents.where((e) => e.category == category).toList();
  }
}
