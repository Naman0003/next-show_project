import 'package:flutter/material.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Profile> _partners = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'pending', 'verified'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPartners() async {
    setState(() => _isLoading = true);
    try {
      final response = await NextShowSupabaseClient.client
          .from('profiles')
          .select()
          .eq('role', 'partner')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _partners = (response as List)
              .map((json) => _profileFromSupabaseJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load partners: $e'),
            backgroundColor: NSColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleVerification(Profile partner, bool verify) async {
    try {
      await NextShowSupabaseClient.client
          .from('profiles')
          .update({'is_verified': verify})
          .eq('id', partner.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verify
                  ? 'Partner ${partner.fullName ?? partner.email} verified successfully!'
                  : 'Verification revoked for ${partner.fullName ?? partner.email}.',
            ),
            backgroundColor: verify ? NSColors.success : NSColors.warning,
          ),
        );
        _loadPartners();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification status: $e'),
            backgroundColor: NSColors.error,
          ),
        );
      }
    }
  }

  List<Profile> get _filteredPartners {
    return _partners.where((partner) {
      // Apply search query filter
      final query = _searchQuery.toLowerCase();
      final nameMatches = partner.fullName?.toLowerCase().contains(query) ?? false;
      final emailMatches = partner.email.toLowerCase().contains(query);
      final matchesSearch = query.isEmpty || nameMatches || emailMatches;

      // Apply status filter
      bool matchesStatus = true;
      if (_statusFilter == 'pending') {
        matchesStatus = !partner.isVerified;
      } else if (_statusFilter == 'verified') {
        matchesStatus = partner.isVerified;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPartners;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const NSLogo(fontSize: 20),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: NSColors.royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ADMIN',
                style: NSTextStyles.labelSmall.copyWith(
                  color: NSColors.royalBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: NSColors.textSecondary),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out of the Admin Portal?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: NSColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await NextShowSupabaseClient.signOut();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search partners by name or email...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                // Filters row
                Row(
                  children: [
                    Text(
                      'Filter Status:',
                      style: NSTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All (${_partners.length})',
                              isSelected: _statusFilter == 'all',
                              onTap: () => setState(() => _statusFilter = 'all'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Pending (${_partners.where((p) => !p.isVerified).length})',
                              isSelected: _statusFilter == 'pending',
                              onTap: () => setState(() => _statusFilter = 'pending'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Verified (${_partners.where((p) => p.isVerified).length})',
                              isSelected: _statusFilter == 'verified',
                              onTap: () => setState(() => _statusFilter = 'verified'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main partner list
          Expanded(
            child: _isLoading
                ? const Center(child: NSLoading(message: 'Loading partner profiles...'))
                : RefreshIndicator(
                    onRefresh: _loadPartners,
                    color: NSColors.royalBlue,
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final partner = filtered[index];
                              return _buildPartnerCard(partner);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NSColors.border.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 48,
                  color: NSColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No partners match your search'
                    : 'No partner registrations found',
                style: NSTextStyles.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try checking spelling or changing filters'
                    : 'When partners register on the organizer app, they will show up here.',
                style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCard(Profile partner) {
    final registrationDate = partner.createdAt.toLocal().toString().substring(0, 10);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: NSColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: NSColors.royalBlue.withOpacity(0.1),
                  child: Text(
                    (partner.fullName ?? partner.email)[0].toUpperCase(),
                    style: NSTextStyles.titleMedium.copyWith(color: NSColors.royalBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (partner.fullName != null) ...[
                        Text(
                          partner.fullName!,
                          style: NSTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        partner.email,
                        style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registered: $registrationDate',
                        style: NSTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(partner.isVerified),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (partner.isVerified)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.block_flipped, size: 16, color: NSColors.error),
                    label: const Text('Revoke Verification', style: TextStyle(color: NSColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NSColors.error),
                    ),
                    onPressed: () => _toggleVerification(partner, false),
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.verified_user_rounded, size: 16),
                    label: const Text('Verify Partner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NSColors.success,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _toggleVerification(partner, true),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified
            ? NSColors.success.withOpacity(0.1)
            : NSColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
            size: 14,
            color: isVerified ? NSColors.success : NSColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending Approval',
            style: NSTextStyles.labelSmall.copyWith(
              color: isVerified ? NSColors.success : NSColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NSColors.royalBlue : Colors.white,
          border: Border.all(
            color: isSelected ? NSColors.royalBlue : NSColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: NSTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : NSColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Maps a Supabase snake_case JSON row to a [Profile] model.
/// The auto-generated Profile.fromJson expects camelCase keys, but Supabase
/// returns snake_case (e.g. created_at, full_name, is_verified).
Profile _profileFromSupabaseJson(Map<String, dynamic> json) {
  return Profile(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    role: _parseUserRole(json['role'] as String?),
    isVerified: json['is_verified'] as bool? ?? false,
    favoriteVenueIds:
        (json['favorite_venue_ids'] as List<dynamic>?)?.cast<String>() ?? [],
    preferredCategories:
        (json['preferred_categories'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

UserRole _parseUserRole(String? value) {
  switch (value) {
    case 'partner':
      return UserRole.partner;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.user;
  }
}
