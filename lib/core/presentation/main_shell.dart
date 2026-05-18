import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:gestion_stock/features/products/presentation/pages/products_page.dart';
import 'package:gestion_stock/features/sales/presentation/pages/sales_page.dart';
import 'package:gestion_stock/features/dashboard/presentation/pages/statistics_page.dart';
import 'package:gestion_stock/features/sales/presentation/pages/invoices_page.dart';

/// Main Shell - Contains the sidebar navigation and content area
/// This is the root layout for the desktop application
class MainShell extends StatefulWidget {
  final VoidCallback onLogout;

  const MainShell({super.key, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Tableau de Bord'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Produits'),
    _NavItem(icon: Icons.point_of_sale_rounded, label: 'Ventes'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Factures'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Statistiques'),
  ];

  final List<Widget> _pages = const [
    DashboardPage(),
    ProductsPage(),
    SalesPage(),
    InvoicesPage(),
    StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // === Sidebar Navigation ===
          _buildSidebar(),
          // === Vertical Divider ===
          Container(width: 1, color: Colors.grey.shade200),
          // === Main Content Area with page transition ===
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220.w,
      color: AppTheme.sidebarColor,
      child: Column(
        children: [
          // Logo / Shop Name
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      'assets/images/sidebar_logo.png',
                      width: 120.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Pièces Moto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Gestion de Stock',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          SizedBox(height: 8.h),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6.r),
                      onTap: () => setState(() => _selectedIndex = index),
                       child: AnimatedContainer(
                         duration: const Duration(milliseconds: 250),
                         curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              size: 18.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Logout button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            child: InkWell(
              onTap: widget.onLogout,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 16.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Footer
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              'Made with ❤️ by Nidhal Boumaiza',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
