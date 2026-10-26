import 'dart:async';
import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getTrendingEvents();
  Future<List<Event>> getEventsByCity(String city);
  Future<List<Event>> getEventsByCategory(EventCategory category);
}

class MockEventRepository implements EventRepository {
  static final List<Event> _mockEvents = [
    Event(
      id: 'evt-1',
      title: 'Travis Fountair Live',
      subtitle: 'Just Another Day 2025 Tour',
      description: 'An open-air acoustic live showcase celebrating independent indie musicians in the heart of Berlin.',
      category: EventCategory.music,
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 2)),
      venueName: 'Tempelhof Field',
      city: 'Berlin',
      isFree: true,
      organizer: 'Berlin Music Collective',
      isTrending: true,
    ),
    Event(
      id: 'evt-2',
      title: 'Open Cinema Under The Stars',
      subtitle: 'Classic Indie Short Films Showcase',
      description: 'Bring a blanket and enjoy free open-air indie film screenings with local filmmakers.',
      category: EventCategory.film,
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 5)),
      venueName: 'Mauerpark Amphitheater',
      city: 'Berlin',
      isFree: true,
      organizer: 'Kino Freiluft',
      isTrending: true,
    ),
    Event(
      id: 'evt-3',
      title: 'Streetball 3v3 Jam',
      subtitle: 'Urban Hoops Championship',
      description: 'Free entry street basketball tournament with live DJ sets, food trucks, and freestyle battles.',
      category: EventCategory.sports,
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 7)),
      venueName: 'Görlitzer Park Courts',
      city: 'Berlin',
      isFree: true,
      organizer: 'Urban Hoops DE',
      isTrending: true,
    ),
    Event(
      id: 'evt-4',
      title: 'Midnight Techno Warehouse Jam',
      subtitle: 'Underground Sound Experiment',
      description: 'Free entry before 1 AM. High-energy electronic beats, ambient visuals, and local DJs.',
      category: EventCategory.nightlife,
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 3)),
      venueName: 'Kulturbrauerei Späti',
      city: 'Berlin',
      isFree: true,
      organizer: 'Berlin Sound Labs',
      isTrending: true,
    ),
    Event(
      id: 'evt-5',
      title: 'Munich Digital Art Expo',
      subtitle: 'Interactive Light & Projection Art',
      description: 'Explore 3D projection mapping and immersive digital art installations for free.',
      category: EventCategory.art,
      imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 4)),
      venueName: 'Kunstareal Munich',
      city: 'Munich',
      isFree: true,
      organizer: 'Munich Art Lab',
      isTrending: false,
    ),
    Event(
      id: 'evt-6',
      title: 'Eisbach Surf Jam',
      subtitle: 'River Wave Invitational',
      description: 'Watch Europe\'s top river surfers tackle the famous Eisbach wave with live commentary.',
      category: EventCategory.sports,
      imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 6)),
      venueName: 'Englischer Garten',
      city: 'Munich',
      isFree: true,
      organizer: 'Eisbach River Surfers',
      isTrending: true,
    ),
    Event(
      id: 'evt-7',
      title: 'Elbe Waterfront Food & Vinyl Fest',
      subtitle: 'Street Food & Record Exchange',
      description: 'Free admission waterfront gathering with artisanal street food vendors and rare vinyl listening booths.',
      category: EventCategory.food,
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 8)),
      venueName: 'St. Pauli Piers',
      city: 'Hamburg',
      isFree: true,
      organizer: 'Hamburg Foodies',
      isTrending: false,
    ),
    Event(
      id: 'evt-8',
      title: 'Schanzenviertel Acoustic Sunset',
      subtitle: 'Indie Folk & Singer-Songwriter Live',
      description: 'Cozy free sunset acoustic session featuring emerging singer-songwriters from across northern Germany.',
      category: EventCategory.music,
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 1)),
      venueName: 'Schanzenpark',
      city: 'Hamburg',
      isFree: true,
      organizer: 'Schanze Sessions',
      isTrending: true,
    ),
    Event(
      id: 'evt-9',
      title: 'Rhine Promenade Community Yoga',
      subtitle: 'Mindful Morning Flow',
      description: 'Free outdoor group yoga and sound bath meditation by the Rhine. All experience levels welcome.',
      category: EventCategory.community,
      imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 3)),
      venueName: 'Rheinpark Köln',
      city: 'Cologne',
      isFree: true,
      organizer: 'Cologne Wellness Collective',
      isTrending: false,
    ),
    Event(
      id: 'evt-10',
      title: 'Frankfurt Tech & AI Hack Night',
      subtitle: 'Building Open Source AI Tools',
      description: 'Free community hackathon for developers, creators, and AI enthusiasts. Snacks and drinks included!',
      category: EventCategory.education,
      imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 9)),
      venueName: 'TechQuartier',
      city: 'Frankfurt',
      isFree: true,
      organizer: 'Frankfurt Devs',
      isTrending: false,
    ),
    Event(
      id: 'evt-11',
      title: 'Leipzig Street Art & Graffiti Jam',
      subtitle: 'Live Mural Creation & DJ Sets',
      description: 'Watch international urban artists transform historic industrial walls into vibrant public murals.',
      category: EventCategory.art,
      imageUrl: 'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 10)),
      venueName: 'Baumwollspinnerei',
      city: 'Leipzig',
      isFree: true,
      organizer: 'Leipzig Art Collective',
      isTrending: true,
    ),
    Event(
      id: 'evt-12',
      title: 'Pop-Up Vintage Flea & Vinyl Market',
      subtitle: 'Thrift Culture & Local Crafts',
      description: 'Free entry pop-up market featuring local artisans, vintage clothing curators, and food pop-ups.',
      category: EventCategory.food,
      imageUrl: 'https://images.unsplash.com/photo-1531058240690-006c446962d8?auto=format&fit=crop&w=1000&q=80',
      startDate: DateTime.now().add(const Duration(days: 11)),
      venueName: 'Karl-Liebknecht-Straße',
      city: 'Leipzig',
      isFree: true,
      organizer: 'Leipzig Thrift Club',
      isTrending: false,
    ),
  ];

  @override
  Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network latency
    return List.unmodifiable(_mockEvents);
  }

  @override
  Future<List<Event>> getTrendingEvents() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockEvents.where((e) => e.isTrending).toList();
  }

  @override
  Future<List<Event>> getEventsByCity(String city) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (city.toLowerCase() == 'all cities' || city.isEmpty) return getEvents();
    return _mockEvents.where((e) => e.city.toLowerCase() == city.toLowerCase()).toList();
  }

  @override
  Future<List<Event>> getEventsByCategory(EventCategory category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (category == EventCategory.all) return getEvents();
    return _mockEvents.where((e) => e.category == category).toList();
  }
}
