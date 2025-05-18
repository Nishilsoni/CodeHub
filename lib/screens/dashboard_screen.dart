import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;
  String? _userName;
  String? _userInitial;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _sidebarAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Get user data from Firestore
      final userData = await _authService.getUserData(user.uid);
      setState(() {
        _userName = userData?['name'] ?? user.displayName ?? 'User';
        _userInitial = _userName!.isNotEmpty ? _userName![0].toUpperCase() : 'U';
      });
    }
  }

  void _showLogoutConfirmation() {
    _animationController.forward();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _animationController.reverse();
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _animationController.reverse());
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildSidebar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blur overlay
            if (_isSidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleSidebar,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5 * _fadeAnimation.value,
                      sigmaY: 5 * _fadeAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                    ),
                  ),
                ),
              ),
            
            // Sidebar
            Positioned(
              left: _sidebarAnimation.value * 250,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: _toggleSidebar,
                          icon: Icon(
                            _isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn()
                          .scale(),
                        const SizedBox(height: 20),
                        ...List.generate(6, (index) => _buildSidebarItem(
                          icon: _getIconForIndex(index),
                          title: _getTitleForIndex(index),
                          index: index,
                        )).animate(interval: const Duration(milliseconds: 50))
                          .fadeIn()
                          .slideX(begin: -0.2),
                        const Spacer(),
                        _buildSidebarItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          index: 6,
                          onTap: _showLogoutConfirmation,
                        ).animate()
                          .fadeIn()
                          .slideY(begin: 0.2),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.home_outlined;
      case 1: return Icons.location_on_outlined;
      case 2: return Icons.add_circle_outline;
      case 3: return Icons.favorite_outline;
      case 4: return Icons.settings_outlined;
      case 5: return Icons.info_outline;
      default: return Icons.home_outlined;
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Nearby Spaces';
      case 2: return 'Add New Space';
      case 3: return 'Favorites';
      case 4: return 'Settings';
      case 5: return 'About';
      default: return 'Home';
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          setState(() {
            _selectedIndex = index;
            if (_isSidebarOpen) {
              _toggleSidebar();
            }
          });
          
          // Navigate to settings screen when settings is selected
          if (index == 4) { // Settings index
            Navigator.pushNamed(context, '/settings');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            _userInitial ?? 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ).animate()
                          .fadeIn()
                          .scale(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                _userName ?? 'User',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleSidebar,
                          icon: Icon(
                            _isSidebarOpen ? Icons.menu_open : Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  'Content for ${_getSelectedPageTitle()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate()
                        .fadeIn()
                        .scale(),
                    ),
                  ],
                ),
              ),
            ),
            // Sidebar
            _buildSidebar(),
          ],
        ),
      ),
    );
  }

  String _getSelectedPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Home';
      case 1: return 'Nearby Spaces';
      case 2: return 'Add New Space';
      case 3: return 'Favorites';
      case 4: return 'Settings';
      case 5: return 'About';
      default: return 'Home';
    }
  }
} 