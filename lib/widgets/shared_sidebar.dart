import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class SharedSidebar extends StatefulWidget {
  final String currentRoute;
  final bool isOpen;
  final VoidCallback onToggle;

  const SharedSidebar({
    super.key,
    required this.currentRoute,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  State<SharedSidebar> createState() => _SharedSidebarState();
}

class _SharedSidebarState extends State<SharedSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
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

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(SharedSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return FadeTransition(
          opacity: animation1,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: Colors.blue.shade900.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String route,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3), width: 1) : null,
      ),
      child: InkWell(
        onTap: onTap,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blur overlay
            if (widget.isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onToggle,
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
              top: statusBarHeight,
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.primaryDelta! < 0) {
                    widget.onToggle();
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    widget.onToggle();
                  }
                },
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
                          _buildSidebarItem(
                            icon: Icons.home_outlined,
                            title: 'Home',
                            route: '/dashboard',
                            isSelected: widget.currentRoute == '/dashboard',
                            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                          ),
                          _buildSidebarItem(
                            icon: Icons.location_on_outlined,
                            title: 'Nearby Spaces',
                            route: '/nearby',
                            isSelected: widget.currentRoute == '/nearby',
                            onTap: () => Navigator.pushReplacementNamed(context, '/nearby'),
                          ),
                          _buildSidebarItem(
                            icon: Icons.add_circle_outline,
                            title: 'Add New Space',
                            route: '/add-space',
                            isSelected: widget.currentRoute == '/add-space',
                            onTap: () => Navigator.pushReplacementNamed(context, '/add-space'),
                          ),
                          _buildSidebarItem(
                            icon: Icons.favorite_outline,
                            title: 'Favorites',
                            route: '/favorites',
                            isSelected: widget.currentRoute == '/favorites',
                            onTap: () => Navigator.pushReplacementNamed(context, '/favorites'),
                          ),
                          _buildSidebarItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            route: '/settings',
                            isSelected: widget.currentRoute == '/settings',
                            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
                          ),
                          _buildSidebarItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            route: '/about',
                            isSelected: widget.currentRoute == '/about',
                            onTap: () => Navigator.pushReplacementNamed(context, '/about'),
                          ),
                          const Spacer(),
                          _buildSidebarItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            route: '/login',
                            onTap: _showLogoutConfirmation,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
} 