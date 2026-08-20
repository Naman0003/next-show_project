// lib/services/ai_recommendation_service.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared/api_keys.dart';
import '../models/event_model.dart';

class AiPick {
  final Event event;
  final String reason;

  AiPick({required this.event, required this.reason});
}

class AiRecommendationResult {
  final String intro;
  final List<AiPick> picks;

  AiRecommendationResult({required this.intro, required this.picks});
}

/// Grounds AI recommendations in what's actually live and bookable right
/// now, instead of asking Gemini to free-associate against its general
/// knowledge (which can suggest things not even playing in Berlin).
class AiRecommendationService {
  // Keeps the prompt (and Gemini token cost) bounded if the live catalog
  // grows large. Plenty of headroom for a single-city MVP.
  static const int _maxEventsInPrompt = 80;

  static Future<AiRecommendationResult> recommend({
    required String userPrompt,
    required List<Event> liveEvents,
  }) async {
    if (liveEvents.isEmpty) {
      throw Exception("No live listings to recommend from.");
    }

    final candidates = liveEvents.take(_maxEventsInPrompt).toList();
    final catalog = candidates
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'category': e.category.name,
              'genre': e.genre,
              'venue': e.venue,
              'price': e.price,
              'when': e.date,
            })
        .toList();

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: ApiKeys.gemini);

    final prompt = '''
You are the Next Show concierge for Berlin. A user describes what they're in
the mood for, and you pick the best matches from what is ACTUALLY live and
bookable right now. Only recommend events from the list below — never
suggest anything outside it, and never invent an "id" that isn't in it.
Consider movies, comedy, music and theatre equally; pick whichever best fit
the user's mood, not just movies.

User's request: "$userPrompt"

Live listings (JSON array, one object per event):
${jsonEncode(catalog)}

Pick 3 to 5 of the best matches. Return ONLY valid JSON, no markdown fences,
in exactly this shape:
{
  "intro": "one friendly sentence introducing the picks",
  "picks": [
    { "id": "<id from the list above>", "reason": "one short sentence on why this fits" }
  ]
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final rawText = response.text ?? "";
    final cleanJson = rawText.replaceAll("```json", "").replaceAll("```", "").trim();
    final decoded = json.decode(cleanJson);

    final String intro = decoded['intro']?.toString() ?? "Here's what's on that matches your mood:";
    final List<dynamic> rawPicks = decoded['picks'] ?? [];

    final eventsById = {for (final e in candidates) e.id: e};

    final picks = rawPicks
        .map((p) {
          final event = eventsById[p['id']?.toString()];
          if (event == null) return null;
          return AiPick(event: event, reason: p['reason']?.toString() ?? '');
        })
        .whereType<AiPick>()
        .toList();

    if (picks.isEmpty) {
      throw Exception("No matching live listings found for that mood.");
    }

    return AiRecommendationResult(intro: intro, picks: picks);
  }
}
