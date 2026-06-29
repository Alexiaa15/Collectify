import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/collection_item.dart';
import '../services/auth_service.dart';
import '../services/collection_service.dart';
import '../utils/app_theme.dart';
import 'collection_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();
  final _collectionService = CollectionService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get currentAccent =>
      _tabController.index == 0 ? AppTheme.accentGame : AppTheme.accentComic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tabController.index == 0
                      ? [AppTheme.accentGame, const Color(0xFF9C6CFC)]
                      : [AppTheme.accentComic, const Color(0xFFFC7C9D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Collectify'),
          ],
        ),
        actions: [
          // Stats
          FutureBuilder<Map<String, int>>(
            future: _collectionService.getStatusCounts(
              widget.user.uid,
              _tabController.index == 0 ? ItemType.game : ItemType.comic,
            ),
            builder: (_, snap) {
              final total = (snap.data ?? {}).values.fold(0, (a, b) => a + b);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: currentAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$total items',
                      style: TextStyle(
                        color: currentAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Profile
          PopupMenuButton<String>(
            color: AppTheme.bgSurface,
            offset: const Offset(0, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) async {
              if (v == 'logout') await _authService.signOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName ?? 'User',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.user.email ?? '',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Color(0xFFF44336), size: 18),
                    SizedBox(width: 10),
                    Text('Sign Out',
                        style: TextStyle(color: Color(0xFFF44336))),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: widget.user.photoURL != null
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
                backgroundColor: AppTheme.accentGame,
                child: widget.user.photoURL == null
                    ? Text(
                        (widget.user.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 2.5,
          indicatorColor: currentAccent,
          labelColor: currentAccent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_esports_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Games', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Comics', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CollectionListScreen(
            userId: widget.user.uid,
            type: ItemType.game,
          ),
          CollectionListScreen(
            userId: widget.user.uid,
            type: ItemType.comic,
          ),
        ],
      ),
    );
  }
}
