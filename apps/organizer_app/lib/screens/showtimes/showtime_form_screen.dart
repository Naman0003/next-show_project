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
  late TextEditingController _languageFormatController;
  late TextEditingController _imageController;

  EventStatus _selectedStatus = EventStatus.published;
  bool _isSaving = false;

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
    }

    _priceController = TextEditingController(text: st?.price?.toString() ?? '12.50');
    _capacityController = TextEditingController(text: st?.capacity?.toString() ?? '120');
    _bookingUrlController = TextEditingController(text: st?.bookingUrl ?? '');
    _languageFormatController = TextEditingController(
      text: st?.attributes['format']?.toString() ?? 'OmU (German Subs)',
    );
    _imageController = TextEditingController(text: st?.imageUrl ?? '');

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
    _languageFormatController.dispose();
    _imageController.dispose();
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
      final format = _languageFormatController.text.trim();
      final attributes = <String, dynamic>{
        if (format.isNotEmpty) 'format': format,
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
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
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
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
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
                    Text('Showtime Details', style: NSTextStyles.titleLarge),
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
                        labelText: 'Event *',
                        prefixIcon: Icon(Icons.movie),
                      ),
                      items: _events.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: isEditing ? null : (val) => setState(() => _selectedEventId = val),
                    ),
                    const SizedBox(height: 16),

                    // Date & Time pickers
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: NSColors.border),
                      ),
                      leading: const Icon(Icons.access_time, color: NSColors.royalBlue),
                      title: const Text('Start Time *'),
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

                    TextFormField(
                      controller: _languageFormatController,
                      decoration: const InputDecoration(
                        labelText: 'Language / Screening Format',
                        hintText: 'e.g. OmU, OV, 3D, IMAX',
                        prefixIcon: Icon(Icons.subtitles),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bookingUrlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Direct Booking URL *',
                        hintText: 'https://cinema.com/tickets/123?ref=nextshow',
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Booking URL is required' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<EventStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
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
