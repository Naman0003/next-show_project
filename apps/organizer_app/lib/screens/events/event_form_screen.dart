// lib/screens/events/event_form_screen.dart
import 'dart:async';
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
  late TextEditingController _directorController;
  late TextEditingController _genresController;
  late TextEditingController _refUrlController;

  EventCategory _selectedCategory = EventCategory.movie;
  EventStatus _selectedStatus = EventStatus.published;
  bool _isSaving = false;
  bool _isCustomIndieMovie = false;
  bool _isLockedFromTmdb = false;
  TmdbMovieDetails? _selectedTmdbDetails;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _imageController = TextEditingController(text: e?.imageUrl ?? '');
    _durationController = TextEditingController(text: e?.durationMinutes?.toString() ?? '');
    _tmdbIdController = TextEditingController(text: e?.externalIds['tmdb_id']?.toString() ?? '');
    _directorController = TextEditingController(text: e?.metadata['director']?.toString() ?? '');
    _genresController = TextEditingController(
      text: (e?.metadata['genres'] as List?)?.join(', ') ?? '',
    );
    _refUrlController = TextEditingController(text: e?.metadata['external_ref_url']?.toString() ?? '');

    if (e != null) {
      _selectedCategory = e.category;
      _selectedStatus = e.status;
      _isCustomIndieMovie = !e.isVerified;
      _isLockedFromTmdb = e.isVerified && e.externalIds['tmdb_id'] != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    _tmdbIdController.dispose();
    _directorController.dispose();
    _genresController.dispose();
    _refUrlController.dispose();
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
        onCustomMovieSelected: () {
          Navigator.pop(context);
          setState(() {
            _isCustomIndieMovie = true;
            _isLockedFromTmdb = false;
            _selectedTmdbDetails = null;
            _tmdbIdController.clear();
          });
        },
      ),
    );

    if (selectedMovie != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching TMDB metadata...')),
      );

      final details = await TmdbService.fetchMovieDetails(selectedMovie.id);

      if (mounted) {
        setState(() {
          _isCustomIndieMovie = false;
          _isLockedFromTmdb = true;
          _selectedTmdbDetails = details;

          _titleController.text = selectedMovie.title;
          _descriptionController.text = details?.overview ?? selectedMovie.overview ?? '';
          _tmdbIdController.text = selectedMovie.id.toString();
          if (details?.posterUrl != null || selectedMovie.fullPosterUrl != null) {
            _imageController.text = details?.posterUrl ?? selectedMovie.fullPosterUrl!;
          }
          if (details?.runtime != null) {
            _durationController.text = details!.runtime.toString();
          }
          _directorController.text = details?.director ?? '';
          _genresController.text = details?.genres.join(', ') ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Locked metadata for "${selectedMovie.title}" (TMDB ID: ${selectedMovie.id})')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLockedFromTmdb && !_isCustomIndieMovie && _selectedCategory == EventCategory.movie) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select a movie from TMDB or tap "Add Custom Movie".'),
          backgroundColor: NSColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final duration = int.tryParse(_durationController.text.trim());
      final tmdbId = _tmdbIdController.text.trim();
      final externalIds = <String, dynamic>{};
      if (tmdbId.isNotEmpty) {
        externalIds['tmdb_id'] = tmdbId;
      }

      final metadata = <String, dynamic>{
        'director': _directorController.text.trim(),
        'genres': _genresController.text
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toList(),
        if (_refUrlController.text.trim().isNotEmpty)
          'external_ref_url': _refUrlController.text.trim(),
        if (_selectedTmdbDetails?.releaseYear != null)
          'release_year': _selectedTmdbDetails!.releaseYear,
      };

      final isVerified = !_isCustomIndieMovie;

      if (widget.event == null) {
        final createdEvent = await OrganizerRepository.createEvent(
          category: _selectedCategory,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          durationMinutes: duration,
          externalIds: externalIds,
          metadata: metadata,
          status: _selectedStatus,
          isVerified: isVerified,
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
          metadata: metadata,
          status: _selectedStatus,
          isVerified: isVerified,
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

              // Movie Search Section
              if (isMovie) ...[
                if (_isLockedFromTmdb) ...[
                  // Selected movie card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NSColors.success.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: NSColors.success.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        if (_imageController.text.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageController.text,
                              width: 44,
                              height: 62,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 44, color: NSColors.success),
                            ),
                          )
                        else
                          const Icon(Icons.check_circle, color: NSColors.success, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleController.text,
                                style: NSTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_directorController.text.isNotEmpty)
                                Text(
                                  'Dir. ${_directorController.text}',
                                  style: NSTextStyles.bodySmall.copyWith(color: NSColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _openTmdbMovieSearch,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isCustomIndieMovie) ...[
                  // Custom movie indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: NSColors.skyBlue.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: NSColors.skyBlue.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note, color: NSColors.skyBlue, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Custom movie — fill in the details below',
                            style: NSTextStyles.bodySmall.copyWith(color: NSColors.skyBlue),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isCustomIndieMovie = false;
                            _isLockedFromTmdb = false;
                          }),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Search field (not yet selected)
                  InkWell(
                    onTap: _openTmdbMovieSearch,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: NSColors.snowWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NSColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: NSColors.textSecondary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search for a movie...',
                              style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],

              Text('Event Details', style: NSTextStyles.titleLarge),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  hintText: _isLockedFromTmdb || _isCustomIndieMovie
                      ? 'e.g. Dune: Part Two'
                      : 'Search for a movie above first',
                  prefixIcon: const Icon(Icons.title),
                  suffixIcon: _isLockedFromTmdb
                      ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                      : !_isCustomIndieMovie
                          ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                          : null,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Synopsis / Description
              TextFormField(
                controller: _descriptionController,
                enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Synopsis / Description *',
                  hintText: _isLockedFromTmdb || _isCustomIndieMovie
                      ? 'Overview, synopsis, or event details...'
                      : 'Search for a movie above first',
                  prefixIcon: const Icon(Icons.description),
                  suffixIcon: _isLockedFromTmdb
                      ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                      : !_isCustomIndieMovie
                          ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                          : null,
                ),
                validator: (val) {
                  if (_isCustomIndieMovie && (val == null || val.trim().isEmpty)) {
                    return 'Synopsis is mandatory for custom indie movies';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Poster URL
              TextFormField(
                controller: _imageController,
                enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Poster Image URL *',
                  hintText: _isLockedFromTmdb || _isCustomIndieMovie
                      ? 'https://...'
                      : 'Search for a movie above first',
                  prefixIcon: const Icon(Icons.image),
                  suffixIcon: _isLockedFromTmdb
                      ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                      : !_isCustomIndieMovie
                          ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                          : null,
                ),
                validator: (val) {
                  if (_isCustomIndieMovie && (val == null || val.trim().isEmpty)) {
                    return 'Poster URL is mandatory for custom indie movies';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duration (min) *',
                        hintText: _isLockedFromTmdb || _isCustomIndieMovie ? '166' : '—',
                        prefixIcon: const Icon(Icons.timer),
                        suffixIcon: _isLockedFromTmdb
                            ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                            : !_isCustomIndieMovie
                                ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                                : null,
                      ),
                      validator: (val) {
                        if (_isCustomIndieMovie && (val == null || val.trim().isEmpty)) {
                          return 'Runtime is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _directorController,
                      enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                      decoration: InputDecoration(
                        labelText: 'Director',
                        hintText: _isLockedFromTmdb || _isCustomIndieMovie ? 'Denis Villeneuve' : '—',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: _isLockedFromTmdb
                            ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                            : !_isCustomIndieMovie
                                ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _genresController,
                enabled: _isLockedFromTmdb ? false : _isCustomIndieMovie,
                decoration: InputDecoration(
                  labelText: 'Genres (comma-separated)',
                  hintText: _isLockedFromTmdb || _isCustomIndieMovie ? 'Sci-Fi, Adventure, Action' : '—',
                  prefixIcon: const Icon(Icons.label),
                  suffixIcon: _isLockedFromTmdb
                      ? const Icon(Icons.lock, size: 18, color: NSColors.textSecondary)
                      : !_isCustomIndieMovie
                          ? const Icon(Icons.block, size: 18, color: NSColors.textSecondary)
                          : null,
                ),
              ),
              const SizedBox(height: 16),

              // Mandatory External Reference Link for Custom Movies
              if (_isCustomIndieMovie) ...[
                TextFormField(
                  controller: _refUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'External Reference Link *',
                    hintText: 'Letterboxd, IMDb, or Festival Program URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (val) {
                    if (_isCustomIndieMovie && (val == null || val.trim().isEmpty)) {
                      return 'Please paste a reference link (Letterboxd, IMDb, or Festival program)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (_tmdbIdController.text.isNotEmpty)
                TextFormField(
                  controller: _tmdbIdController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'TMDB ID',
                    prefixIcon: Icon(Icons.fingerprint),
                    suffixIcon: Icon(Icons.lock, size: 18, color: NSColors.textSecondary),
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
  final VoidCallback onCustomMovieSelected;

  const _TmdbSearchBottomSheet({
    this.initialQuery = '',
    required this.onCustomMovieSelected,
  });

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

    final query = text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
        _networkError = null;
      });
      return;
    }

    if (query.length < 2) return;

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
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
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Find a Movie', style: NSTextStyles.titleLarge),
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
                hintText: 'Search by title (e.g. Dune, Inception)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _performSearch,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 12),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: NSLoading(message: 'Searching...'),
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
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: NSEmptyState(
                  icon: Icons.movie_outlined,
                  title: 'No Results Found',
                  subtitle: 'Can\'t find your movie? Add it manually.',
                  action: NSPrimaryButton(
                    label: 'Add a custom movie',
                    icon: Icons.add,
                    onPressed: widget.onCustomMovieSelected,
                  ),
                ),
              )
            else ...[
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
                            Text(movie.releaseYear, style: NSTextStyles.labelSmall),
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
              // Bottom custom movie fallback
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: widget.onCustomMovieSelected,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("Didn't find your movie? Add a custom movie."),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
