// lib/screens/events/event_form_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import '../../services/tmdb_service.dart';
import '../showtimes/showtime_form_screen.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _durationController;
  late TextEditingController _tmdbIdController;

  EventCategory _selectedCategory = EventCategory.movie;
  EventStatus _selectedStatus = EventStatus.published;
  bool _isSaving = false;
  TmdbMovieSearchResult? _selectedTmdbMovie;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _imageController = TextEditingController(text: e?.imageUrl ?? '');
    _durationController = TextEditingController(text: e?.durationMinutes?.toString() ?? '');
    _tmdbIdController = TextEditingController(text: e?.externalIds['tmdb_id']?.toString() ?? '');

    if (e != null) {
      _selectedCategory = e.category;
      _selectedStatus = e.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    _tmdbIdController.dispose();
    super.dispose();
  }

  Future<void> _openTmdbMovieSearch() async {
    final selectedMovie = await showModalBottomSheet<TmdbMovieSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NSColors.snowWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TmdbSearchBottomSheet(
        initialQuery: _titleController.text.trim(),
      ),
    );

    if (selectedMovie != null && mounted) {
      setState(() => _selectedTmdbMovie = selectedMovie);
      _titleController.text = selectedMovie.title;
      _descriptionController.text = selectedMovie.overview ?? '';
      _tmdbIdController.text = selectedMovie.id.toString();
      if (selectedMovie.fullPosterUrl != null) {
        _imageController.text = selectedMovie.fullPosterUrl!;
      }

      // Fetch runtime
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching TMDB movie details...')),
      );
      final runtime = await TmdbService.fetchMovieRuntime(selectedMovie.id);
      if (runtime != null && mounted) {
        _durationController.text = runtime.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected "${selectedMovie.title}" from TMDB!')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final duration = int.tryParse(_durationController.text.trim());
      final tmdbId = _tmdbIdController.text.trim();
      final externalIds = <String, dynamic>{};
      if (tmdbId.isNotEmpty) {
        externalIds['tmdb_id'] = tmdbId;
      }

      if (widget.event == null) {
        final createdEvent = await OrganizerRepository.createEvent(
          category: _selectedCategory,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          durationMinutes: duration,
          externalIds: externalIds,
          status: _selectedStatus,
        );

        if (mounted) {
          Navigator.pop(context, true);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShowtimeFormScreen(initialEventId: createdEvent.id),
            ),
          );
        }
      } else {
        await OrganizerRepository.updateEvent(
          id: widget.event!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          durationMinutes: duration,
          externalIds: externalIds,
          status: _selectedStatus,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e'), backgroundColor: NSColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    final isMovie = _selectedCategory == EventCategory.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Category & Status', style: NSTextStyles.titleLarge),
              const SizedBox(height: 16),

              DropdownButtonFormField<EventCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: EventCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<EventStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Publishing Status *',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: EventStatus.values.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: Text(st.name[0].toUpperCase() + st.name.substring(1)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 24),

              // TMDB Search Banner for Movies
              if (isMovie) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NSColors.royalBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NSColors.royalBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.movie_filter, color: NSColors.royalBlue),
                          const SizedBox(width: 8),
                          Text('TMDB Movie Database', style: NSTextStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Search TMDB to auto-fill official title, synopsis, poster, and runtime.',
                        style: NSTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      NSPrimaryButton(
                        label: _selectedTmdbMovie != null
                            ? 'Change TMDB Movie Selection'
                            : 'Search & Pick TMDB Movie',
                        icon: Icons.search,
                        onPressed: _openTmdbMovieSearch,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text('Event Details', style: NSTextStyles.titleLarge),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title *',
                  hintText: 'e.g. Dune: Part Two',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Overview, synopsis, or event details...',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        hintText: '166',
                        prefixIcon: Icon(Icons.timer),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tmdbIdController,
                      decoration: const InputDecoration(
                        labelText: 'TMDB ID',
                        hintText: '693134',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Poster Image URL',
                  hintText: 'https://image.tmdb.org/...',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 24),

              NSPrimaryButton(
                label: isEditing ? 'Save Changes' : 'Create Event',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TmdbSearchBottomSheet extends StatefulWidget {
  final String initialQuery;

  const _TmdbSearchBottomSheet({this.initialQuery = ''});

  @override
  State<_TmdbSearchBottomSheet> createState() => _TmdbSearchBottomSheetState();
}

class _TmdbSearchBottomSheetState extends State<_TmdbSearchBottomSheet> {
  late TextEditingController _searchController;
  List<TmdbMovieSearchResult> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _networkError;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().length >= 2) {
      _performSearch();
    }
  }

  void _onSearchChanged(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (text.trim().length < 2) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _networkError = null;
    });

    try {
      final results = await TmdbService.searchMovies(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _networkError = 'Search error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: keyboardPadding + 20,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Search TMDB Movies', style: NSTextStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Type 2+ letters (e.g. Dune, Inception)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _performSearch,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: NSLoading(message: 'Searching TMDB database...'),
              )
            else if (_networkError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: NSErrorState(
                  message: _networkError!,
                  onRetry: _performSearch,
                ),
              )
            else if (_hasSearched && _results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: NSEmptyState(
                  icon: Icons.movie_outlined,
                  title: 'No Movies Found',
                  subtitle: 'Try typing 2 or more characters (e.g. "Dune").',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final movie = _results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: movie.fullPosterUrl != null
                            ? Image.network(
                                movie.fullPosterUrl!,
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 75,
                                  color: NSColors.border,
                                  child: const Icon(Icons.movie, color: NSColors.textSecondary),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 75,
                                color: NSColors.border,
                                child: const Icon(Icons.movie, color: NSColors.textSecondary),
                              ),
                      ),
                      title: Text(
                        movie.title,
                        style: NSTextStyles.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movie.releaseYear.isNotEmpty)
                            Text('Released: ${movie.releaseYear}', style: NSTextStyles.labelSmall),
                          if (movie.overview != null && movie.overview!.isNotEmpty)
                            Text(
                              movie.overview!,
                              style: NSTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      onTap: () => Navigator.pop(context, movie),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
