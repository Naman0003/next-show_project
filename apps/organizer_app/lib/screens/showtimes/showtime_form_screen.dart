// lib/screens/showtimes/showtime_form_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';

class ShowtimeFormScreen extends StatefulWidget {
  final Showtime? showtime;
  final String? initialVenueId;
  final String? initialEventId;

  const ShowtimeFormScreen({
    super.key,
    this.showtime,
    this.initialVenueId,
    this.initialEventId,
  });

  @override
  State<ShowtimeFormScreen> createState() => _ShowtimeFormScreenState();
}

class _ShowtimeFormScreenState extends State<ShowtimeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Venue> _venues = [];
  List<Event> _events = [];
  bool _isLoadingDropdowns = true;

  String? _selectedVenueId;
  String? _selectedEventId;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 2));
  DateTime? _endTime;

  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _bookingUrlController;
  late TextEditingController _screenNameController;

  String _selectedAudioSubtitle = 'OmU';
  String _selectedFormat = '2D';
  EventStatus _selectedStatus = EventStatus.published;
  bool _isSaving = false;

  final List<String> _audioSubtitleOptions = ['OmU', 'OmeU', 'DF', 'OV', 'Original'];
  final List<String> _formatOptions = ['2D', '3D', 'IMAX 2D', 'IMAX 3D', '35mm', '70mm', '4K'];

  @override
  void initState() {
    super.initState();
    final st = widget.showtime;

    _selectedVenueId = st?.venueId ?? widget.initialVenueId;
    _selectedEventId = st?.eventId ?? widget.initialEventId;

    if (st != null) {
      _startTime = st.startTime;
      _endTime = st.endTime;
      _selectedStatus = st.status;
      _selectedAudioSubtitle = st.attributes['audio_subtitle']?.toString() ?? 'OmU';
      _selectedFormat = st.attributes['format']?.toString() ?? '2D';
    }

    _priceController = TextEditingController(text: st?.price?.toString() ?? '12.50');
    _capacityController = TextEditingController(text: st?.capacity?.toString() ?? '120');
    _bookingUrlController = TextEditingController(text: st?.bookingUrl ?? '');
    _screenNameController = TextEditingController(
      text: st?.attributes['screen_name']?.toString() ?? 'Hall 1',
    );

    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      final venues = await OrganizerRepository.fetchMyVenues();
      final events = await OrganizerRepository.fetchEvents();
      setState(() {
        _venues = venues;
        _events = events;
        if (_selectedVenueId == null && _venues.isNotEmpty) {
          _selectedVenueId = _venues.first.id;
        }
        if (_selectedEventId == null && _events.isNotEmpty) {
          _selectedEventId = _events.first.id;
        }
        _isLoadingDropdowns = false;
      });
    } catch (_) {
      setState(() => _isLoadingDropdowns = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _capacityController.dispose();
    _bookingUrlController.dispose();
    _screenNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? _startTime : (_endTime ?? _startTime.add(const Duration(hours: 2)));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVenueId == null || _selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a Venue and an Event')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final price = double.tryParse(_priceController.text.trim());
      final capacity = int.tryParse(_capacityController.text.trim());
      final screenName = _screenNameController.text.trim();

      final attributes = <String, dynamic>{
        'screen_name': screenName.isEmpty ? 'Hall 1' : screenName,
        'audio_subtitle': _selectedAudioSubtitle,
        'format': _selectedFormat,
      };

      if (widget.showtime == null) {
        await OrganizerRepository.createShowtime(
          venueId: _selectedVenueId!,
          eventId: _selectedEventId!,
          startTime: _startTime,
          endTime: _endTime,
          price: price,
          capacity: capacity,
          attributes: attributes,
          bookingUrl: _bookingUrlController.text.trim(),
          status: _selectedStatus,
        );
      } else {
        await OrganizerRepository.updateShowtime(
          id: widget.showtime!.id,
          startTime: _startTime,
          endTime: _endTime,
          price: price,
          capacity: capacity,
          attributes: attributes,
          bookingUrl: _bookingUrlController.text.trim(),
          status: _selectedStatus,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.showtime == null ? 'Showtime scheduled!' : 'Showtime updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving showtime: $e'), backgroundColor: NSColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.showtime != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Showtime' : 'Schedule Showtime'),
      ),
      body: _isLoadingDropdowns
          ? const NSLoading(message: 'Loading venues & events...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Performance Location & Movie', style: NSTextStyles.titleLarge),
                    const SizedBox(height: 16),

                    // Venue Selector
                    DropdownButtonFormField<String>(
                      value: _selectedVenueId,
                      decoration: const InputDecoration(
                        labelText: 'Venue *',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _venues.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text(v.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: isEditing ? null : (val) => setState(() => _selectedVenueId = val),
                    ),
                    const SizedBox(height: 16),

                    // Event Selector
                    DropdownButtonFormField<String>(
                      value: _selectedEventId,
                      decoration: const InputDecoration(
                        labelText: 'Movie / Event Entity *',
                        prefixIcon: Icon(Icons.movie),
                      ),
                      items: _events.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Row(
                            children: [
                              Text(e.title, overflow: TextOverflow.ellipsis),
                              if (!e.isVerified) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: NSColors.skyBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Indie', style: TextStyle(fontSize: 10, color: NSColors.skyBlue)),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: isEditing ? null : (val) => setState(() => _selectedEventId = val),
                    ),
                    const SizedBox(height: 24),

                    Text('Screening Time & Hall Parameters', style: NSTextStyles.titleLarge),
                    const SizedBox(height: 16),

                    // Date & Time pickers
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: NSColors.border),
                      ),
                      leading: const Icon(Icons.access_time, color: NSColors.royalBlue),
                      title: const Text('Screening Date & Start Time *'),
                      subtitle: Text(
                        '${_startTime.day}/${_startTime.month}/${_startTime.year} at ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                        style: NSTextStyles.titleSmall,
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 20),
                      onTap: () => _pickDateTime(isStart: true),
                    ),
                    const SizedBox(height: 12),

                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: NSColors.border),
                      ),
                      leading: const Icon(Icons.more_time, color: NSColors.skyBlue),
                      title: const Text('End Time (Optional)'),
                      subtitle: Text(
                        _endTime == null
                            ? 'Not specified'
                            : '${_endTime!.day}/${_endTime!.month}/${_endTime!.year} at ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                        style: NSTextStyles.bodyMedium,
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 20),
                      onTap: () => _pickDateTime(isStart: false),
                    ),
                    const SizedBox(height: 16),

                    // Hall / Screen Name
                    TextFormField(
                      controller: _screenNameController,
                      decoration: const InputDecoration(
                        labelText: 'Screen / Hall Name *',
                        hintText: 'e.g. Hall 1, Kino 3, Auditorium A',
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Screen/Hall name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Audio / Subtitle Tag Selector
                    Text('Audio / Subtitle Tag *', style: NSTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _audioSubtitleOptions.map((tag) {
                        final isSelected = _selectedAudioSubtitle == tag;
                        return ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: NSColors.royalBlue.withOpacity(0.2),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedAudioSubtitle = tag);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Format Selector
                    Text('Screening Format *', style: NSTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _formatOptions.map((fmt) {
                        final isSelected = _selectedFormat == fmt;
                        return ChoiceChip(
                          label: Text(fmt),
                          selected: isSelected,
                          selectedColor: NSColors.skyBlue.withOpacity(0.2),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFormat = fmt);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    Text('Pricing & Booking', style: NSTextStyles.titleLarge),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Ticket Price (€)',
                              hintText: '12.50',
                              prefixIcon: Icon(Icons.euro),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Seat Capacity',
                              hintText: '120',
                              prefixIcon: Icon(Icons.event_seat),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Direct Booking URL
                    TextFormField(
                      controller: _bookingUrlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Direct Booking URL *',
                        hintText: 'https://kino-berlin.de/booking/showtime/12345',
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Direct booking URL is required';
                        if (!val.startsWith('http')) return 'Enter a valid URL starting with http:// or https://';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    NSPrimaryButton(
                      label: isEditing ? 'Save Changes' : 'Schedule Showtime',
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
