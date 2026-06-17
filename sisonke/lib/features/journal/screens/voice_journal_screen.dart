import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  State<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  static const _prefsKey = 'voice_journal_entries';

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  List<String> _savedPaths = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPaths = prefs.getStringList(_prefsKey) ?? [];
    });
  }

  Future<void> _saveEntry(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [path, ..._savedPaths];
    await prefs.setStringList(_prefsKey, updated);
    setState(() => _savedPaths = updated);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null && path.isNotEmpty) {
        await _saveEntry(path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice entry saved.')),
          );
        }
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission is required to record voice entries.',
              ),
            ),
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/voice_journal_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _deleteEntry(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _savedPaths.where((p) => p != path).toList();
    await prefs.setStringList(_prefsKey, updated);
    setState(() => _savedPaths = updated);
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  String _labelFromPath(String path) {
    final fileName = path.split('/').last.split('\\').last;
    final tsStr = fileName
        .replaceAll('voice_journal_', '')
        .replaceAll('.m4a', '');
    try {
      final ms = int.parse(tsStr);
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateFormat('MMM dd, yyyy  hh:mm a').format(dt);
    } catch (_) {
      return fileName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Voice Journal'),
      body: Container(
        decoration: const BoxDecoration(gradient: SisonkeColors.forestBreeze),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          children: [
            // ── Record button ──────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? SisonkeColors.riskHigh.withOpacity(0.15)
                            : SisonkeColors.primaryDim,
                        border: Border.all(
                          color: _isRecording
                              ? SisonkeColors.riskHigh
                              : SisonkeColors.primary,
                          width: _isRecording ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                    ? SisonkeColors.riskHigh
                                    : SisonkeColors.primary)
                                .withOpacity(0.18),
                            blurRadius: _isRecording ? 24 : 12,
                            spreadRadius: _isRecording ? 4 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 52,
                        color: _isRecording
                            ? SisonkeColors.riskHigh
                            : SisonkeColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording ? 'Tap to stop' : 'Tap to record',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isRecording
                          ? SisonkeColors.riskHigh
                          : const Color(0xFF2F3433).withOpacity(0.65),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: SisonkeColors.riskHigh,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recording...',
                          style: TextStyle(
                            fontSize: 12,
                            color: SisonkeColors.riskHigh,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),
            // ── Saved recordings ───────────────────────────────────────
            if (_savedPaths.isNotEmpty) ...[
              Text(
                'Saved recordings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              ..._savedPaths.map((path) => _RecordingTile(
                    label: _labelFromPath(path),
                    onDelete: () => _deleteEntry(path),
                  )),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Your voice entries will appear here.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF2F3433).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Recording tile ───────────────────────────────────────────────────────────
class _RecordingTile extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _RecordingTile({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SisonkeColors.primaryDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_rounded,
              size: 18,
              color: SisonkeColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F3433),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: const Color(0xFF2F3433).withOpacity(0.4),
            onPressed: onDelete,
            tooltip: 'Delete recording',
          ),
        ],
      ),
    );
  }
}
