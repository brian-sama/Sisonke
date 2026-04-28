import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_api.dart';

class SisonkeAdminApp extends StatefulWidget {
  const SisonkeAdminApp({super.key});

  @override
  State<SisonkeAdminApp> createState() => _SisonkeAdminAppState();
}

class _SisonkeAdminAppState extends State<SisonkeAdminApp> {
  AdminApi? _api;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _api = AdminApi(prefs));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF168AAD),
        secondary: const Color(0xFF7B61FF),
        tertiary: const Color(0xFFFF5A8A),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    );

    return MaterialApp(
      title: 'Sisonke Admin',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _api == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : AdminShell(api: _api!),
    );
  }
}

class AdminShell extends StatefulWidget {
  final AdminApi api;

  const AdminShell({super.key, required this.api});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  var _authenticated = false;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _authenticated = widget.api.isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return AdminLoginScreen(
        api: widget.api,
        onLoggedIn: () => setState(() => _authenticated = true),
      );
    }

    final pages = [
      AdminOverviewScreen(api: widget.api),
      AdminResourcesScreen(api: widget.api),
      AdminEmergencyContactsScreen(api: widget.api),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.admin_panel_settings_rounded),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: Text('Resources'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.health_and_safety_outlined),
                selectedIcon: Icon(Icons.health_and_safety_rounded),
                label: Text('Emergency'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(
                  onLogout: () async {
                    await widget.api.logout();
                    setState(() => _authenticated = false);
                  },
                ),
                Expanded(child: pages[_index]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _AdminTopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              'Sisonke Admin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  final AdminApi api;
  final VoidCallback onLoggedIn;

  const AdminLoginScreen({super.key, required this.api, required this.onLoggedIn});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.favorite_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Admin sign in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _loading ? null : _login,
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login_rounded),
                    label: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.login(_email.text, _password.text);
      widget.onLoggedIn();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class AdminOverviewScreen extends StatelessWidget {
  final AdminApi api;

  const AdminOverviewScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: api.overview(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Analytics overview', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricCard(title: 'Resources', value: '${data['resources']?['total'] ?? 0}', icon: Icons.menu_book_rounded),
                _MetricCard(title: 'Emergency contacts', value: '${data['emergencyContacts']?['total'] ?? 0}', icon: Icons.health_and_safety_rounded),
                _MetricCard(title: 'Questions', value: '${data['questions']?['total'] ?? 0}', icon: Icons.forum_rounded),
                _MetricCard(title: 'Recent events', value: '${(data['analytics'] as Map?)?.values.fold<int>(0, (a, b) => a + (b as int)) ?? 0}', icon: Icons.query_stats_rounded),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  Text(title),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminResourcesScreen extends StatefulWidget {
  final AdminApi api;

  const AdminResourcesScreen({super.key, required this.api});

  @override
  State<AdminResourcesScreen> createState() => _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends State<AdminResourcesScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.api.resources();

  @override
  Widget build(BuildContext context) {
    return _AdminTablePage(
      title: 'Resources',
      actionLabel: 'New resource',
      onAdd: () => _openResourceEditor(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.map((item) {
              return DataRow(cells: [
                DataCell(Text('${item['title']}')),
                DataCell(Text('${item['category']}')),
                DataCell(Chip(label: Text('${item['status']}'))),
                DataCell(Row(
                  children: [
                    IconButton(onPressed: () => _openResourceEditor(item: item), icon: const Icon(Icons.edit_rounded), tooltip: 'Edit'),
                    IconButton(onPressed: () => _publish(item['id'] as String), icon: const Icon(Icons.publish_rounded), tooltip: 'Publish'),
                    IconButton(onPressed: () => _archive(item['id'] as String), icon: const Icon(Icons.archive_rounded), tooltip: 'Archive'),
                  ],
                )),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _publish(String id) async {
    await widget.api.publishResource(id);
    setState(() => _future = widget.api.resources());
  }

  Future<void> _archive(String id) async {
    await widget.api.archiveResource(id);
    setState(() => _future = widget.api.resources());
  }

  Future<void> _openResourceEditor({Map<String, dynamic>? item}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ResourceEditor(api: widget.api, item: item),
    );
    if (saved == true) setState(() => _future = widget.api.resources());
  }
}

class AdminEmergencyContactsScreen extends StatefulWidget {
  final AdminApi api;

  const AdminEmergencyContactsScreen({super.key, required this.api});

  @override
  State<AdminEmergencyContactsScreen> createState() => _AdminEmergencyContactsScreenState();
}

class _AdminEmergencyContactsScreenState extends State<AdminEmergencyContactsScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.api.emergencyContacts();

  @override
  Widget build(BuildContext context) {
    return _AdminTablePage(
      title: 'Emergency contacts',
      actionLabel: 'New contact',
      onAdd: () => _openEditor(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.map((item) {
              return DataRow(cells: [
                DataCell(Text('${item['name']}')),
                DataCell(Text('${item['phoneNumber']}')),
                DataCell(Text('${item['category']}')),
                DataCell(Chip(label: Text('${item['status']}'))),
                DataCell(IconButton(onPressed: () => _openEditor(item: item), icon: const Icon(Icons.edit_rounded))),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _openEditor({Map<String, dynamic>? item}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EmergencyContactEditor(api: widget.api, item: item),
    );
    if (saved == true) setState(() => _future = widget.api.emergencyContacts());
  }
}

class _AdminTablePage extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAdd;
  final Widget child;

  const _AdminTablePage({required this.title, required this.actionLabel, required this.onAdd, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const Spacer(),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: Text(actionLabel)),
          ],
        ),
        const SizedBox(height: 20),
        Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: child)),
      ],
    );
  }
}

class _ResourceEditor extends StatefulWidget {
  final AdminApi api;
  final Map<String, dynamic>? item;

  const _ResourceEditor({required this.api, this.item});

  @override
  State<_ResourceEditor> createState() => _ResourceEditorState();
}

class _ResourceEditorState extends State<_ResourceEditor> {
  late final _title = TextEditingController(text: widget.item?['title'] as String?);
  late final _description = TextEditingController(text: widget.item?['description'] as String?);
  late final _content = TextEditingController(text: widget.item?['content'] as String?);
  var _category = 'mental-health';
  var _status = 'draft';

  @override
  void initState() {
    super.initState();
    _category = widget.item?['category'] as String? ?? _category;
    _status = widget.item?['status'] as String? ?? _status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New resource' : 'Edit resource'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const ['mental-health', 'srhr', 'emergency', 'substance-use', 'wellness', 'guide']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['draft', 'review', 'published', 'archived']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 12),
              TextField(controller: _content, minLines: 8, maxLines: 14, decoration: const InputDecoration(labelText: 'Content')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    await widget.api.saveResource({
      'title': _title.text,
      'description': _description.text,
      'content': _content.text,
      'category': _category,
      'status': _status,
      'language': 'en',
      'isOfflineAvailable': true,
    }, id: widget.item?['id'] as String?);
    if (mounted) Navigator.pop(context, true);
  }
}

class _EmergencyContactEditor extends StatefulWidget {
  final AdminApi api;
  final Map<String, dynamic>? item;

  const _EmergencyContactEditor({required this.api, this.item});

  @override
  State<_EmergencyContactEditor> createState() => _EmergencyContactEditorState();
}

class _EmergencyContactEditorState extends State<_EmergencyContactEditor> {
  late final _name = TextEditingController(text: widget.item?['name'] as String?);
  late final _phone = TextEditingController(text: widget.item?['phoneNumber'] as String?);
  late final _description = TextEditingController(text: widget.item?['description'] as String?);
  var _category = 'crisis';
  var _status = 'draft';

  @override
  void initState() {
    super.initState();
    _category = widget.item?['category'] as String? ?? _category;
    _status = widget.item?['status'] as String? ?? _status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New contact' : 'Edit contact'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone number')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const ['crisis', 'mental-health', 'srhr', 'general']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['draft', 'review', 'published', 'archived']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    await widget.api.saveEmergencyContact({
      'name': _name.text,
      'phoneNumber': _phone.text,
      'category': _category,
      'status': _status,
      'description': _description.text,
      'country': 'ZW',
      'isActive': true,
    }, id: widget.item?['id'] as String?);
    if (mounted) Navigator.pop(context, true);
  }
}
