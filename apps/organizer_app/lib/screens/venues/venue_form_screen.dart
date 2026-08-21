// lib/screens/venues/venue_form_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';

class VenueFormScreen extends StatefulWidget {
  final Venue? venue;

  const VenueFormScreen({super.key, this.venue});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _websiteController;
  late TextEditingController _imageController;
  late TextEditingController _notesController;

  VenueType _selectedType = VenueType.cinema;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameController = TextEditingController(text: v?.name ?? '');
    _addressController = TextEditingController(text: v?.address ?? '');
    _latController = TextEditingController(text: v?.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: v?.longitude?.toString() ?? '');
    _websiteController = TextEditingController(text: v?.websiteUrl ?? '');
    _imageController = TextEditingController(text: v?.imageUrl ?? '');
    _notesController = TextEditingController(text: v?.partnerNotes ?? '');

    if (v != null) {
      _selectedType = v.venueType;
      _isActive = v.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _websiteController.dispose();
    _imageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());

      if (widget.venue == null) {
        await OrganizerRepository.createVenue(
          name: _nameController.text.trim(),
          venueType: _selectedType,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          latitude: lat,
          longitude: lng,
          websiteUrl: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          partnerNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
        await OrganizerRepository.updateVenue(
          id: widget.venue!.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          latitude: lat,
          longitude: lng,
          websiteUrl: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          partnerNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          isActive: _isActive,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.venue == null ? 'Venue created!' : 'Venue updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving venue: $e'), backgroundColor: NSColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.venue != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Venue' : 'Create Venue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Venue Information', style: NSTextStyles.titleLarge),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Venue Name *',
                  hintText: 'e.g. Babylon Rosa-Luxemburg-Platz',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Venue name is required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<VenueType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Venue Type *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: VenueType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'e.g. Rosa-Luxemburg-Straße 30, 10178 Berlin',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '52.5273',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '13.4116',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://babylonberlin.eu',
                  prefixIcon: Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Photo Image URL',
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Internal Partner Notes',
                  hintText: 'Contact info, box office opening hours, technical specs...',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 16),

              if (isEditing)
                SwitchListTile(
                  title: const Text('Venue Active'),
                  subtitle: const Text('Active venues appear in user searches'),
                  value: _isActive,
                  activeColor: NSColors.royalBlue,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              const SizedBox(height: 24),

              NSPrimaryButton(
                label: isEditing ? 'Save Changes' : 'Create Venue',
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
