import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/shared/widgets/index.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  final Set<String> _selectedTopics = {};

  final List<Map<String, dynamic>> _topics = [
    {
      'id': 'mental_health',
      'title': 'Mental Health',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFF168AAD),
      'desc': 'Anxiety, depression, coping mechanisms, and emotional well-being.',
    },
    {
      'id': 'stress',
      'title': 'Stress Management',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF2E6F60),
      'desc': 'Mindfulness, relaxation techniques, and academic or work-life balance.',
    },
    {
      'id': 'relationships',
      'title': 'Relationship Support',
      'icon': Icons.people_alt_rounded,
      'color': const Color(0xFF7B61FF),
      'desc': 'Healthy communication, boundary setting, conflict resolution, and support.',
    },
    {
      'id': 'srhr',
      'title': 'Sexual & Reproductive Health',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF5A8A),
      'desc': 'Safe sex practices, family planning, hygiene, and reproductive wellness.',
    },
    {
      'id': 'substance',
      'title': 'Substance Use Recovery',
      'icon': Icons.healing_rounded,
      'color': const Color(0xFFE63946),
      'desc': 'Sobriety trackers, relapse prevention, triggers, and recovery support.',
    },
    {
      'id': 'self_care',
      'title': 'Self-Care & Growth',
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFFF4A261),
      'desc': 'Healthy habits, self-esteem, goal setting, and journal prompts.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTopics();
  }

  Future<void> _loadSelectedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('user_selected_topics') ?? [];
    if (mounted) {
      setState(() {
        _selectedTopics.clear();
        _selectedTopics.addAll(saved);
      });
    }
  }

  Future<void> _saveSelectedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_selected_topics', _selectedTopics.toList());
    if (!mounted) return;
    
    // Check if onboarding is completed
    final completed = prefs.getBool('onboarding_completed') ?? false;
    if (!completed) {
      await prefs.setBool('onboarding_completed', true);
    }
    
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Choose Topics'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Personalize Your Space',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E6F60),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the topics that interest you most. This will personalize your resources and companion suggestions.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    final isSelected = _selectedTopics.contains(topic['id']);
                    final color = topic['color'] as Color;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTopics.remove(topic['id']);
                          } else {
                            _selectedTopics.add(topic['id'] as String);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.08) : Colors.white,
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: color.withOpacity(isSelected ? 0.2 : 0.1),
                              child: Icon(topic['icon'] as IconData, color: color),
                            ),
                            const Spacer(),
                            Text(
                              topic['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topic['desc'] as String,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? color.withOpacity(0.8) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selectedTopics.isEmpty ? null : _saveSelectedTopics,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6F60),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save and Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
