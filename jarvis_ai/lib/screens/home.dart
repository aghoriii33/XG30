import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/vfx.dart';

// Provider to watch current time
final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now())
      .startWith(DateTime.now());
});

extension StreamX<T> on Stream<T> {
  Stream<T> startWith(T value) {
    return Stream<T>.multi((controller) {
      controller.add(value);
      listen(controller.add,
          onError: controller.addError, onDone: controller.close);
    });
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final List<String> _filters = ["Content", "Writing", "Research & Analytics"];
  String _selectedFilter = "Content";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _recentChats = [
    {
      "title": "Greeting assistant preview",
      "time": "Just now",
      "model": "ChatGPT-5 Pro",
    },
    {
      "title": "UI inspiration for purple theme",
      "time": "2 hours ago",
      "model": "Gemini 3.1 Pro",
    },
    {
      "title": "Visual Studio high based research",
      "time": "Yesterday",
      "model": "Claude 3.5 Sonnet",
    },
  ];

  final List<Map<String, dynamic>> _aiModels = [
    {
      "name": "ChatGPT-5 Pro",
      "icon": Icons.auto_awesome_rounded,
      "color": const Color(0xFF10A37F),
      "badge": "MAX",
    },
    {
      "name": "Gemini 3.1",
      "icon": Icons.blur_on_rounded,
      "color": const Color(0xFF4285F4),
      "badge": "HIGH",
    },
    {
      "name": "Claude Sonnet",
      "icon": Icons.psychology_rounded,
      "color": const Color(0xFFD97706),
      "badge": "THINK",
    },
    {
      "name": "DeepSeek-V3",
      "icon": Icons.grain_rounded,
      "color": const Color(0xFF06B6D4),
      "badge": "R1",
    },
    {
      "name": "Grok 2.0",
      "icon": Icons.all_inclusive_rounded,
      "color": const Color(0xFFEC4899),
      "badge": "X",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    if (hour < 21) return "Good evening";
    return "Good night";
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "🌅";
    if (hour < 17) return "☀️";
    if (hour < 21) return "🌆";
    return "🌙";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider);
    final userName = user?.name ?? 'Alex Smith';
    final userEmail = user?.email ?? 'alex.smith@jarvis.ai';
    final greeting = _getGreeting();
    final emoji = _getGreetingEmoji();

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      body: AuroraBackground(
        child: ParticleField(
          particleCount: 35,
          child: ScanlineOverlay(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

            // Top Header: Avatar + Greetings + Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // User Avatar with glow
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.6),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6)
                                .withOpacity(0.25 * _pulseAnimation.value),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Welcome Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              greeting,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(emoji, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        ShimmerText(
                          userName,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: const [
                            Color(0xFFFFFFFF),
                            Color(0xFF8B5CF6),
                            Color(0xFF06B6D4),
                            Color(0xFFFFFFFF),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification + Menu
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Icon(Icons.notifications_none_rounded,
                            color: Colors.white.withOpacity(0.7), size: 18),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        offset: const Offset(0, 50),
                        color: const Color(0xFF131121),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Icon(Icons.more_vert_rounded,
                              color: Colors.white.withOpacity(0.7), size: 18),
                        ),
                        onSelected: (value) {
                          if (value == 'logout') {
                            ref
                                .read(authServiceProvider.notifier)
                                .signOut();
                            context.go('/login');
                          } else if (value == 'settings') {
                            context.push('/settings');
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(
                              userEmail,
                              style: GoogleFonts.outfit(
                                  color: Colors.white60, fontSize: 13),
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'settings',
                            child: Row(
                              children: [
                                const Icon(Icons.settings_rounded,
                                    color: Color(0xFF8B5CF6), size: 18),
                                const SizedBox(width: 8),
                                Text("Settings",
                                    style: GoogleFonts.outfit(
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                const Icon(Icons.logout_rounded,
                                    color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text("Sign Out",
                                    style: GoogleFonts.outfit(
                                        color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Large Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're on a wave",
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                    ).createShader(bounds),
                    child: Text(
                      "of productivity!",
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.05),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6)
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Models Horizontal Scroll Row
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _aiModels.length,
                        itemBuilder: (context, index) {
                          final model = _aiModels[index];
                          return GestureDetector(
                            onTap: () => context.push('/chat'),
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (model['color'] as Color)
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: (model['color'] as Color)
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(model['icon'] as IconData,
                                      color: model['color'] as Color,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          model['name'] as String,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: (model['color'] as Color)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            model['badge'] as String,
                                            style: GoogleFonts.outfit(
                                              color: model['color'] as Color,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
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

                    // Large Card: Image Generation
                    GestureDetector(
                      onTap: () => context.push('/explore'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(0.12),
                              const Color(0xFF131121).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF8B5CF6).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF8B5CF6),
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF8B5CF6).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "DALL-E 3 • Imagen",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF8B5CF6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Image Generation",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Creates high-quality custom images using DALL-E 3 & Imagen based on any prompt.",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildTagChip("1024×1024"),
                                const SizedBox(width: 8),
                                _buildTagChip("4K Export"),
                                const SizedBox(width: 8),
                                _buildTagChip("Variations"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Row with Left & Right Cards
                    Row(
                      children: [
                        // Left Card: Voice Commander
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/voice'),
                            child: Container(
                              height: 150,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6D28D9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF8B5CF6).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.mic_rounded,
                                      color: Colors.white, size: 26),
                                  const Spacer(),
                                  Text(
                                    "Voice\nCommander",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Hands-free AI",
                                    style: GoogleFonts.outfit(
                                        color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Right Cards Column
                        Expanded(
                          child: Column(
                            children: [
                              // E2EE Badge Card
                              GestureDetector(
                                onTap: () => context.push('/settings'),
                                child: Container(
                                  height: 65,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: const Color(0xFF0D9488)
                                            .withOpacity(0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lock_rounded,
                                          color: Color(0xFF0D9488), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "E2EE\nEnabled",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF0D9488),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Code Snippets Card
                              GestureDetector(
                                onTap: () => context.push('/chat'),
                                child: Container(
                                  height: 75,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131121)
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.06)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.code_rounded,
                                          color: Colors.white, size: 20),
                                      const Spacer(),
                                      Text(
                                        "Code snippets",
                                        style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Platform Support Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131121).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Available on All Platforms",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPlatformBadge(
                                  Icons.phone_android_rounded, "Android", const Color(0xFF78C257)),
                              _buildPlatformBadge(
                                  Icons.phone_iphone_rounded, "iOS", const Color(0xFF5AC8FA)),
                              _buildPlatformBadge(
                                  Icons.web_rounded, "Web", const Color(0xFF8B5CF6)),
                              _buildPlatformBadge(
                                  Icons.desktop_windows_rounded, "Windows", const Color(0xFF00B4D8)),
                              _buildPlatformBadge(
                                  Icons.laptop_mac_rounded, "macOS", const Color(0xFFE5E7EB)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Chat Section
                    Row(
                      children: [
                        Text(
                          "Recent chats",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/chat'),
                          child: Text(
                            "View all",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF8B5CF6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // List of recent chats
                    ..._recentChats.map((chat) {
                      return GestureDetector(
                        onTap: () => context.push('/chat'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B5CF6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chat['title']!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      chat['model'] as String,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                chat['time']!,
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.white24, size: 16),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(activeRoute: '/home'),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: const Color(0xFF8B5CF6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlatformBadge(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
