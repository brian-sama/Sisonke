import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_api.dart';
import 'package:sisonke/core/services/chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
      AdminCounselorScreen(api: widget.api),
      AdminCommunityModerationScreen(api: widget.api),
      AdminCmsScreen(api: widget.api),
      AdminResourcesScreen(api: widget.api),
      AdminEmergencyContactsScreen(api: widget.api),
      AdminAnalyticsScreen(api: widget.api),
      AdminUsersSecurityScreen(api: widget.api),
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
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.priority_high_outlined),
                selectedIcon: Icon(Icons.priority_high_rounded),
                label: Text('Risk Alerts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: Text('Moderation'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.web_stories_outlined),
                selectedIcon: Icon(Icons.web_stories_rounded),
                label: Text('CMS'),
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
              NavigationRailDestination(
                icon: Icon(Icons.query_stats_outlined),
                selectedIcon: Icon(Icons.query_stats_rounded),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                label: Text('Security'),
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
              'Sisonke Operations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 12),
            Chip(
              avatar: Icon(Icons.health_and_safety_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
              label: const Text('Safety dashboard'),
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

class AdminCounselorScreen extends ConsumerStatefulWidget {
  final AdminApi api;

  const AdminCounselorScreen({super.key, required this.api});

  @override
  ConsumerState<AdminCounselorScreen> createState() => _AdminCounselorScreenState();
}

class _AdminCounselorScreenState extends ConsumerState<AdminCounselorScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.api.counselorCases();

  @override
  Widget build(BuildContext context) {
    return _AdminTablePage(
      title: 'Counselor dashboard',
      actionLabel: 'Refresh',
      onAdd: () => setState(() => _future = widget.api.counselorCases()),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return DataTable(
            columns: const [
              DataColumn(label: Text('Issue')),
              DataColumn(label: Text('Risk')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.map((item) {
              final id = item['id'] as String;
              return DataRow(cells: [
                DataCell(Text('${item['issueCategory'] ?? item['issue_category']}')),
                DataCell(Chip(label: Text('${item['riskLevel'] ?? item['risk_level']}'))),
                DataCell(Text('${item['status']}')),
                DataCell(Row(
                  children: [
                    IconButton(onPressed: () => _openChat(item), icon: const Icon(Icons.chat_rounded), tooltip: 'Live chat'),
                    IconButton(onPressed: () => _setStatus(id, 'live'), icon: const Icon(Icons.check_circle_outline_rounded), tooltip: 'Accept case'),
                    IconButton(onPressed: () => _setStatus(id, 'emergency'), icon: const Icon(Icons.priority_high_rounded), tooltip: 'Escalate emergency'),
                    IconButton(onPressed: () => _setStatus(id, 'follow-up'), icon: const Icon(Icons.event_available_rounded), tooltip: 'Schedule follow-up'),
                    IconButton(onPressed: () => _addNote(id), icon: const Icon(Icons.note_add_rounded), tooltip: 'Add private note'),
                    IconButton(onPressed: () => _setStatus(id, 'resolved'), icon: const Icon(Icons.check_circle_rounded), tooltip: 'Mark resolved'),
                  ],
                )),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _setStatus(String id, String status) async {
    await widget.api.updateCounselorCaseStatus(id, status);
    setState(() => _future = widget.api.counselorCases());
  }

  Future<void> _addNote(String id) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Private counselor note'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (note == null || note.trim().isEmpty) return;
    await widget.api.addCounselorNote(id, note.trim());
  }

  Future<void> _openChat(Map<String, dynamic> item) async {
    final id = item['id'] as String;
    final category = '${item['issueCategory'] ?? item['issue_category'] ?? 'Support'}';
    
    // Ensure case is at least 'assigned' or 'live' before chatting
    if (item['status'] == 'requested') {
      await _setStatus(id, 'assigned');
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: _AdminLiveChatView(caseId: id, title: category),
      ),
    );
  }
}

class _AdminLiveChatView extends ConsumerStatefulWidget {
  final String caseId;
  final String title;

  const _AdminLiveChatView({required this.caseId, required this.title});

  @override
  ConsumerState<_AdminLiveChatView> createState() => _AdminLiveChatViewState();
}

class _AdminLiveChatViewState extends ConsumerState<_AdminLiveChatView> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    // Extract user ID from token or assume admin for now (ideally passed from API)
    _userId = 'admin'; 

    if (token != null && mounted) {
      final chatService = ref.read(chatServiceProvider);
      chatService.connect(token);
      chatService.joinCase(widget.caseId);

      chatService.messages.listen((msg) {
        if (msg['caseId'] == widget.caseId && mounted) {
          setState(() => _messages.add(msg));
        }
      });
    }
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatServiceProvider).sendMessage(widget.caseId, text);
    setState(() {
      _messages.add({
        'content': text,
        'senderId': _userId,
        'senderRole': 'counselor',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Support: ${widget.title}'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['senderRole'] == 'counselor' || msg['senderRole'] == 'admin';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(msg['content']),
                        const SizedBox(height: 4),
                        Text(
                          isMe ? 'You' : 'User',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type reply...', border: OutlineInputBorder()),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCommunityModerationScreen extends StatefulWidget {
  final AdminApi api;

  const AdminCommunityModerationScreen({super.key, required this.api});

  @override
  State<AdminCommunityModerationScreen> createState() => _AdminCommunityModerationScreenState();
}

class _AdminCommunityModerationScreenState extends State<AdminCommunityModerationScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.api.communityPosts();
  late Future<List<Map<String, dynamic>>> _reportsFuture = widget.api.reports();

  @override
  Widget build(BuildContext context) {
    return _AdminTablePage(
      title: 'Community moderation',
      actionLabel: 'Refresh',
      onAdd: () => setState(() => _future = widget.api.communityPosts()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return DataTable(
                columns: const [
                  DataColumn(label: Text('Age group')),
                  DataColumn(label: Text('Post')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map((item) {
                  final id = item['id'] as String;
                  return DataRow(cells: [
                    DataCell(Text('${item['ageGroup'] ?? item['age_group']}')),
                    DataCell(SizedBox(width: 360, child: Text('${item['content']}', maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Chip(label: Text('${item['status']}'))),
                    DataCell(Row(
                      children: [
                        IconButton(onPressed: () => _moderate(id, 'approved'), icon: const Icon(Icons.check_rounded), tooltip: 'Approve'),
                        IconButton(onPressed: () => _moderate(id, 'removed'), icon: const Icon(Icons.delete_outline_rounded), tooltip: 'Remove'),
                      ],
                    )),
                  ]);
                }).toList(),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Reports queue', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _reportsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return DataTable(
                columns: const [
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map((item) {
                  final id = item['id'] as String;
                  return DataRow(cells: [
                    DataCell(Text('${item['type']}')),
                    DataCell(SizedBox(width: 300, child: Text('${item['reason']}', overflow: TextOverflow.ellipsis))),
                    DataCell(Chip(label: Text('${item['status']}'))),
                    DataCell(Row(
                      children: [
                        IconButton(onPressed: () => _setReport(id, 'resolved'), icon: const Icon(Icons.task_alt_rounded), tooltip: 'Resolve'),
                        IconButton(onPressed: () => _setReport(id, 'dismissed'), icon: const Icon(Icons.block_rounded), tooltip: 'Dismiss'),
                      ],
                    )),
                  ]);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _moderate(String id, String status) async {
    await widget.api.moderateCommunityPost(id, status, reason: status == 'removed' ? 'Removed by moderator' : null);
    setState(() => _future = widget.api.communityPosts());
  }

  Future<void> _setReport(String id, String status) async {
    await widget.api.updateReportStatus(id, status);
    setState(() => _reportsFuture = widget.api.reports());
  }
}

class AdminCmsScreen extends StatefulWidget {
  final AdminApi api;

  const AdminCmsScreen({super.key, required this.api});

  @override
  State<AdminCmsScreen> createState() => _AdminCmsScreenState();
}

class _AdminCmsScreenState extends State<AdminCmsScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.api.cmsContent();

  @override
  Widget build(BuildContext context) {
    return _AdminTablePage(
      title: 'Content management',
      actionLabel: 'New content',
      onAdd: _openEditor,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.map((item) {
              return DataRow(cells: [
                DataCell(Text('${item['title']}')),
                DataCell(Text('${item['contentType'] ?? item['content_type']}')),
                DataCell(Text('${item['category']}')),
                DataCell(Chip(label: Text('${item['status']}'))),
                DataCell(Row(
                  children: [
                    IconButton(onPressed: () => _openEditor(item: item), icon: const Icon(Icons.edit_rounded), tooltip: 'Edit'),
                    IconButton(onPressed: () => _publish(item), icon: const Icon(Icons.publish_rounded), tooltip: 'Publish'),
                    IconButton(onPressed: () => _archive(item), icon: const Icon(Icons.archive_rounded), tooltip: 'Archive'),
                  ],
                )),
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
      builder: (_) => _CmsEditor(api: widget.api, item: item),
    );
    if (saved == true) setState(() => _future = widget.api.cmsContent());
  }

  Future<void> _publish(Map<String, dynamic> item) async {
    await widget.api.saveCmsContent({'status': 'published'}, id: item['id'] as String);
    setState(() => _future = widget.api.cmsContent());
  }

  Future<void> _archive(Map<String, dynamic> item) async {
    await widget.api.saveCmsContent({'status': 'archived'}, id: item['id'] as String);
    setState(() => _future = widget.api.cmsContent());
  }
}

class _CmsEditor extends StatefulWidget {
  final AdminApi api;
  final Map<String, dynamic>? item;

  const _CmsEditor({required this.api, this.item});

  @override
  State<_CmsEditor> createState() => _CmsEditorState();
}

class _CmsEditorState extends State<_CmsEditor> {
  late final _title = TextEditingController(text: widget.item?['title'] as String?);
  late final _body = TextEditingController(text: widget.item?['body'] as String?);
  var _contentType = 'article';
  var _category = 'Mental Health';
  var _status = 'draft';

  @override
  void initState() {
    super.initState();
    _contentType = widget.item?['contentType'] as String? ?? widget.item?['content_type'] as String? ?? _contentType;
    _category = widget.item?['category'] as String? ?? _category;
    _status = widget.item?['status'] as String? ?? _status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New CMS content' : 'Edit CMS content'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _contentType,
                decoration: const InputDecoration(labelText: 'Content type'),
                items: const ['article', 'srhr', 'event', 'helpline', 'faq', 'video', 'daily-prompt', 'announcement']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _contentType = value ?? _contentType),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const ['Mental Health', 'SRHR', 'Substance Abuse', 'Relationships', 'Self-Care', 'Youth Opportunities', 'Emergency Support']
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
              TextField(controller: _body, minLines: 8, maxLines: 14, decoration: const InputDecoration(labelText: 'Body')),
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
    await widget.api.saveCmsContent({
      'title': _title.text,
      'body': _body.text,
      'contentType': _contentType,
      'category': _category,
      'status': _status,
    }, id: widget.item?['id'] as String?);
    if (mounted) Navigator.pop(context, true);
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
            Text('Operations dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('A safety-first view of content, support activity, and platform health.'),
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

class AdminAnalyticsScreen extends StatelessWidget {
  final AdminApi api;

  const AdminAnalyticsScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: api.analytics(days: 7),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        final timeSeries = List<Map<String, dynamic>>.from(data['timeSeries'] ?? []);
        
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Insights', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Simple totals about app use and safety', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _AppUseChart(timeSeries: timeSeries, totalVisits: data['total'] ?? 0),
                    _UrgentHelpChart(timeSeries: timeSeries, totalUrgent: data['counselorEscalations'] ?? 0),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            _PrivacyPromiseCard(),
            const SizedBox(height: 32),
            Text('Demographics & Trends', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _AnalyticsMap(title: 'Age ranges', values: Map<String, dynamic>.from((data['ageRangeDistribution'] as Map?) ?? {})),
                _AnalyticsMap(title: 'Gender distribution', values: Map<String, dynamic>.from((data['genderDistribution'] as Map?) ?? {})),
                _AnalyticsMap(title: 'Mood trends', values: Map<String, dynamic>.from((data['moodTrendsByMood'] as Map?) ?? {})),
                _AnalyticsMap(title: 'Issue categories', values: Map<String, dynamic>.from((data['issueCategories'] as Map?) ?? {})),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AppUseChart extends StatelessWidget {
  final List<Map<String, dynamic>> timeSeries;
  final int totalVisits;

  const _AppUseChart({required this.timeSeries, required this.totalVisits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 480,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5E36FF), Color(0xFF4A19FF)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E36FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'APP USE',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: timeSeries.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value['appUse'] as num).toDouble() + 5,
                        color: Colors.white.withValues(alpha: e.key % 2 == 0 ? 1 : 0.4),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(totalVisits / 1000).toStringAsFixed(1)}k',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'USUAL VISITS',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '+14%',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'CHANGE',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UrgentHelpChart extends StatelessWidget {
  final List<Map<String, dynamic>> timeSeries;
  final int totalUrgent;

  const _UrgentHelpChart({required this.timeSeries, required this.totalUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4B6E), size: 20),
              const SizedBox(width: 8),
              Text(
                'URGENT HELP OVER TIME',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B6E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ELEVATED RISK',
                  style: TextStyle(color: Color(0xFFFF4B6E), fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) return const SizedBox();
                        final index = value.toInt();
                        if (index < 0 || index >= timeSeries.length) return const SizedBox();
                        final date = DateTime.parse(timeSeries[index]['date']);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('d MMM').format(date),
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: timeSeries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['urgent'] as num).toDouble() + 2);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFFF4B6E),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _MiniStat(
                icon: Icons.shield_rounded,
                color: const Color(0xFFFF4B6E),
                value: '$totalUrgent',
                label: 'URGENT REQUESTS',
              ),
              const SizedBox(width: 48),
              const _MiniStat(
                icon: Icons.people_rounded,
                color: Color(0xFF5E36FF),
                value: '98%',
                label: 'HELP RATE',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _MiniStat({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _PrivacyPromiseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFEBB0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFAB00),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy promise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF855D00))),
                SizedBox(height: 4),
                Text(
                  '"These numbers are summaries only. We do not show private chats or journal notes here. We only share aggregated data to improve our services."',
                  style: TextStyle(color: Color(0xFF855D00), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUsersSecurityScreen extends StatefulWidget {
  final AdminApi api;

  const AdminUsersSecurityScreen({super.key, required this.api});

  @override
  State<AdminUsersSecurityScreen> createState() => _AdminUsersSecurityScreenState();
}

class _AdminUsersSecurityScreenState extends State<AdminUsersSecurityScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture = widget.api.users();
  late Future<List<Map<String, dynamic>>> _logsFuture = widget.api.securityLogs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Text('Users & security', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => setState(() {
                _usersFuture = widget.api.users();
                _logsFuture = widget.api.securityLogs();
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Email/device')),
                    DataColumn(label: Text('Suspended')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: snapshot.data!.map((item) {
                    final id = item['id'] as String;
                    final suspended = item['isSuspended'] == true || item['is_suspended'] == true;
                    return DataRow(cells: [
                      DataCell(Text('${item['role']}')),
                      DataCell(Text('${item['email'] ?? item['id']}')),
                      DataCell(Chip(label: Text(suspended ? 'Yes' : 'No'))),
                      DataCell(IconButton(
                        onPressed: () => _setSuspension(id, !suspended),
                        icon: Icon(suspended ? Icons.lock_open_rounded : Icons.block_rounded),
                        tooltip: suspended ? 'Unsuspend' : 'Suspend',
                      )),
                    ]);
                  }).toList(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Security logs', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Event')),
                    DataColumn(label: Text('IP')),
                    DataColumn(label: Text('When')),
                  ],
                  rows: snapshot.data!.map((item) {
                    return DataRow(cells: [
                      DataCell(Text('${item['event']}')),
                      DataCell(Text('${item['ipAddress'] ?? item['ip_address'] ?? ''}')),
                      DataCell(Text('${item['createdAt'] ?? item['created_at'] ?? ''}')),
                    ]);
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setSuspension(String id, bool suspended) async {
    await widget.api.setUserSuspension(id, suspended, reason: suspended ? 'Suspended from admin dashboard' : null);
    setState(() {
      _usersFuture = widget.api.users();
      _logsFuture = widget.api.securityLogs();
    });
  }
}

class _AnalyticsMap extends StatelessWidget {
  final String title;
  final Map<String, dynamic> values;

  const _AnalyticsMap({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (values.isEmpty)
              const Text('No data yet')
            else
              ...values.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.key)),
                        Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
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
