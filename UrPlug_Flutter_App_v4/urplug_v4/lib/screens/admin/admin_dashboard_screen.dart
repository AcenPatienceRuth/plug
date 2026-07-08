import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/provider_profile.dart';
import '../../models/zone.dart';
import '../../models/service_category.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;

  void _goToTab(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.admin_panel_settings_outlined, size: 20),
          SizedBox(width: 8),
          Text('Admin Console'),
        ]),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out of admin',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(children: [
        // Stats bar
        Container(
          color: AppColors.deepBlue.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _StatPill('Providers', '${MockData.providers.length}',
                Icons.storefront_outlined),
            const SizedBox(width: 10),
            _StatPill(
                'Pending',
                '${MockData.providers.where((p) => p.tier == ProviderTier.standard).length}',
                Icons.pending_outlined),
            const SizedBox(width: 10),
            _StatPill('Reviews', '${MockData.reviews.length}',
                Icons.rate_review_outlined),
            const SizedBox(width: 10),
            _StatPill('Jobs', '${MockData.jobPosts.length}',
                Icons.work_outline),
          ]),
        ),
        // Tab bar
        Container(
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _AdminTab('Overview',   Icons.dashboard_outlined,     0, _tab, _goToTab),
              _AdminTab('Verify',     Icons.verified_user_outlined, 1, _tab, _goToTab),
              _AdminTab('Reviews',    Icons.rate_review_outlined,   2, _tab, _goToTab),
              _AdminTab('Users',      Icons.people_outline,         3, _tab, _goToTab),
              _AdminTab('Zones',      Icons.map_outlined,           4, _tab, _goToTab),
              _AdminTab('Categories', Icons.category_outlined,      5, _tab, _goToTab),
            ]),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: [
              _OverviewTab(onNavigate: _goToTab),
              const _VerificationQueueTab(),
              const _ReviewsTab(),
              const _UsersTab(),
              const _ZonesTab(),
              const _CategoriesTab(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Overview ────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _OverviewTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // (label, icon, description, target tab index — null means no tab yet)
    final sections = [
      ('Verification Queue',  Icons.verified_user_outlined,  'Review Gold Tier document submissions', 1),
      ('Review Moderation',   Icons.rate_review_outlined,    'Flag or remove abusive reviews', 2),
      ('User Management',     Icons.people_outline,          'Suspend or remove accounts', 3),
      ('Zone Configuration',  Icons.map_outlined,            'Add or edit administrative zones', 4),
      ('Category Management', Icons.category_outlined,       'Add, edit, or remove service categories', 5),
      ('Platform Analytics',  Icons.bar_chart_outlined,      'Views, chats, registrations over time', null),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Quick Access'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: sections
              .map((s) => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final targetTab = s.$4;
                      if (targetTab != null) {
                        onNavigate(targetTab);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Platform Analytics is not wired to a data source yet.')),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(s.$2, color: AppColors.primaryGreen, size: 22),
                          const Spacer(),
                          Text(s.$1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 3),
                          Text(s.$3,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Verification Queue ───────────────────────────────────────────────────────
class _VerificationQueueTab extends StatefulWidget {
  const _VerificationQueueTab();

  @override
  State<_VerificationQueueTab> createState() => _VerificationQueueTabState();
}

class _VerificationQueueTabState extends State<_VerificationQueueTab> {
  late final List<ProviderProfile> _pending = MockData.providers
      .where((p) => p.tier == ProviderTier.standard)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Pending Gold Tier Applications'),
        const SizedBox(height: 10),
        if (_pending.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No pending applications.')))
        else
          ..._pending.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('PENDING',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text(p.businessDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65))),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _pending.remove(p));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${p.name} rejected.'),
                                backgroundColor: AppColors.danger,
                              ));
                            },
                            icon: const Icon(Icons.close,
                                size: 16, color: AppColors.danger),
                            label: const Text('Reject',
                                style: TextStyle(color: AppColors.danger)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.danger)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _pending.remove(p));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('${p.name} approved as Gold Tier.'),
                                backgroundColor: AppColors.success,
                              ));
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

// ─── Reviews ─────────────────────────────────────────────────────────────────
class _ReviewsTab extends StatefulWidget {
  const _ReviewsTab();

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  late final List reviews = List.from(MockData.reviews);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('All Public Reviews'),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          const Center(child: Text('No reviews.'))
        else
          ...reviews.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(r.consumerDisplayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                        Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      i < r.stars
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 14,
                                      color: AppColors.gold,
                                    ))),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.comment),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => reviews.remove(r));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Review removed.')));
                          },
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.danger),
                          label: const Text('Remove',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

// ─── Users ───────────────────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  late final List<ProviderProfile> _providers = List.from(MockData.providers);
  final Set<String> _suspendedIds = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Registered Providers'),
        const SizedBox(height: 10),
        if (_providers.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No providers left.')))
        else
          ..._providers.map((p) {
            final suspended = _suspendedIds.contains(p.id);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: suspended
                    ? AppColors.danger.withValues(alpha: 0.15)
                    : AppColors.primaryGreenLight,
                child: Text(p.name[0],
                    style: TextStyle(
                        color: suspended
                            ? AppColors.danger
                            : AppColors.primaryGreen,
                        fontWeight: FontWeight.w700)),
              ),
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(suspended
                  ? 'Suspended'
                  : (p.tier == ProviderTier.gold
                      ? '⭐ Gold Verified'
                      : 'Standard')),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'suspend',
                      child: Text(suspended
                          ? 'Reinstate account'
                          : 'Suspend account')),
                  const PopupMenuItem(
                      value: 'remove', child: Text('Remove account')),
                ],
                onSelected: (v) {
                  if (v == 'suspend') {
                    setState(() {
                      if (suspended) {
                        _suspendedIds.remove(p.id);
                      } else {
                        _suspendedIds.add(p.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${suspended ? 'Reinstated' : 'Suspended'}: ${p.name}'),
                    ));
                  } else {
                    setState(() {
                      _providers.remove(p);
                      _suspendedIds.remove(p.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Removed: ${p.name}'),
                    ));
                  }
                },
              ),
            );
          }),
      ],
    );
  }
}

// ─── Zones ───────────────────────────────────────────────────────────────────
class _ZonesTab extends StatefulWidget {
  const _ZonesTab();

  @override
  State<_ZonesTab> createState() => _ZonesTabState();
}

class _ZonesTabState extends State<_ZonesTab> {
  late final List<Zone> _zones = List.from(MockData.zones);

  Future<void> _addZone() async {
    final zone = await showDialog<Zone>(
      context: context,
      builder: (_) => _ZoneFormDialog(existingZones: _zones),
    );
    if (zone == null) return;
    setState(() => _zones.add(zone));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added zone "${zone.name}".')));
  }

  Future<void> _editZone(Zone zone) async {
    final updated = await showDialog<Zone>(
      context: context,
      builder: (_) => _ZoneFormDialog(existingZones: _zones, initial: zone),
    );
    if (updated == null) return;
    setState(() {
      final i = _zones.indexWhere((z) => z.id == zone.id);
      if (i != -1) _zones[i] = updated;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Updated "${updated.name}".')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Administrative Zones'),
        const SizedBox(height: 4),
        Text(
          'These drive the no-GPS location matching engine. '
          'Add sub-counties and parishes as provider coverage expands.',
          style: TextStyle(
              fontSize: 12.5,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 14),
        ..._zones.map((z) {
          final levelLabel = zoneLevelLabel(z.level);
          final parentLabel =
              z.parentId != null ? ' › parent: ${z.parentId}' : '';
          return ListTile(
            dense: true,
            leading: Icon(_levelIcon(z.level),
                size: 18, color: AppColors.primaryGreen),
            title: Text(z.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5)),
            subtitle: Text('$levelLabel$parentLabel',
                style: const TextStyle(fontSize: 11.5)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _editZone(z),
            ),
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _addZone,
          icon: const Icon(Icons.add),
          label: const Text('Add Zone'),
        ),
      ],
    );
  }

  IconData _levelIcon(ZoneLevel level) {
    switch (level) {
      case ZoneLevel.region:   return Icons.public_outlined;
      case ZoneLevel.district: return Icons.location_city_outlined;
      case ZoneLevel.division: return Icons.place_outlined;
      case ZoneLevel.parish:   return Icons.where_to_vote_outlined;
    }
  }
}

String zoneLevelLabel(ZoneLevel level) {
  switch (level) {
    case ZoneLevel.region:   return 'Region';
    case ZoneLevel.district: return 'District';
    case ZoneLevel.division: return 'Division / Sub-county';
    case ZoneLevel.parish:   return 'Parish / Village';
  }
}

/// The level a zone of [level] must be parented under, or null if it's
/// top-level (regions have no parent).
ZoneLevel? _parentLevelFor(ZoneLevel level) {
  switch (level) {
    case ZoneLevel.region:   return null;
    case ZoneLevel.district: return ZoneLevel.region;
    case ZoneLevel.division: return ZoneLevel.district;
    case ZoneLevel.parish:   return ZoneLevel.division;
  }
}

class _ZoneFormDialog extends StatefulWidget {
  final List<Zone> existingZones;
  final Zone? initial;
  const _ZoneFormDialog({required this.existingZones, this.initial});

  @override
  State<_ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<_ZoneFormDialog> {
  late final _nameController =
      TextEditingController(text: widget.initial?.name ?? '');
  late ZoneLevel _level = widget.initial?.level ?? ZoneLevel.parish;
  String? _parentId = widget.initial?.parentId;

  @override
  Widget build(BuildContext context) {
    final requiredParentLevel = _parentLevelFor(_level);
    final parentOptions = requiredParentLevel == null
        ? <Zone>[]
        : widget.existingZones
            .where((z) => z.level == requiredParentLevel)
            .toList();

    if (_parentId != null && !parentOptions.any((z) => z.id == _parentId)) {
      _parentId = null;
    }

    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Zone' : 'Edit Zone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Zone name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ZoneLevel>(
              initialValue: _level,
              decoration: const InputDecoration(labelText: 'Level'),
              items: ZoneLevel.values
                  .map((l) => DropdownMenuItem(
                      value: l, child: Text(zoneLevelLabel(l))))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _level = v);
              },
            ),
            const SizedBox(height: 16),
            if (requiredParentLevel == null)
              Text(
                'Regions are top-level and have no parent.',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _parentId,
                decoration: InputDecoration(
                    labelText: 'Parent ${zoneLevelLabel(requiredParentLevel)}'),
                items: parentOptions
                    .map((z) =>
                        DropdownMenuItem(value: z.id, child: Text(z.name)))
                    .toList(),
                onChanged: (v) => setState(() => _parentId = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            if (requiredParentLevel != null && _parentId == null) return;
            Navigator.of(context).pop(Zone(
              id: widget.initial?.id ??
                  'z_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              level: _level,
              parentId: _parentId,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ─── Categories ──────────────────────────────────────────────────────────────
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  late final List<ServiceCategory> _categories =
      List.from(DefaultCategories.all);

  Future<void> _addCategory() async {
    final category = await showDialog<ServiceCategory>(
      context: context,
      builder: (_) => _CategoryFormDialog(existing: _categories),
    );
    if (category == null) return;
    setState(() => _categories.add(category));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added category "${category.label}".')));
  }

  void _removeCategory(ServiceCategory category) {
    setState(() => _categories.remove(category));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed "${category.label}".')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Service Categories'),
        const SizedBox(height: 10),
        ..._categories.map((c) => ListTile(
              dense: true,
              leading: Icon(c.icon, size: 20, color: AppColors.primaryGreen),
              title: Text(c.label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle:
                  c.isSystemDefault ? const Text('Default category') : null,
              trailing: c.isSystemDefault
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.danger),
                      onPressed: () => _removeCategory(c),
                    ),
            )),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'To promote an "Others" listing to its own category, add it '
            'here, then update the categoryId of providers who registered '
            'under "Others" to match.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _addCategory,
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final List<ServiceCategory> existing;
  const _CategoryFormDialog({required this.existing});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _labelController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: TextField(
        controller: _labelController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Category label',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) {
              setState(() => _error = 'Enter a category name.');
              return;
            }
            final id = label
                .toLowerCase()
                .trim()
                .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                .replaceAll(RegExp(r'^_+|_+$'), '');
            if (widget.existing.any((c) => c.id == id)) {
              setState(() => _error = 'A category with that name already exists.');
              return;
            }
            Navigator.of(context).pop(ServiceCategory(
              id: id,
              label: label,
              icon: Icons.category_outlined,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatPill(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primaryGreenDark)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.primaryGreenDark)),
        ]),
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  const _AdminTab(this.label, this.icon, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primaryGreen : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? AppColors.primaryGreen
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.primaryGreen
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 15));
  }
}
