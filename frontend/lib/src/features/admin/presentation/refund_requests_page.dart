import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'admin_navigation.dart';
import 'widgets/admin_profile_menu.dart';
import 'widgets/refund_requests_panel.dart';

class RefundRequestsPage extends StatelessWidget {
  const RefundRequestsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Refund Requests',
      navigationItems:
          adminNavigationItems(
        AppRoutes.adminRefunds,
      ),
      navigationFooter:
          const AdminProfileMenu(),
      body: Container(
        color: const Color(0xFFF8F9FB),
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            Text(
              'Refund Requests',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Review and manage subscription refund requests.',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 20),

            RefundRequestsPanel(),
          ],
        ),
      ),
    );
  }
}