import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    required this.title,
    required this.navigationItems,
    required this.body,
    super.key,
  });

  final String title;
  final List<NavigationItem> navigationItems;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= 900;
        final navigation = _NavigationList(items: navigationItems);

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          drawer: useSidebar ? null : Drawer(child: navigation),
          body: Row(
            children: [
              if (useSidebar)
                SizedBox(
                  width: 260,
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: navigation,
                  ),
                ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool selected;
}

class _NavigationList extends StatelessWidget {
  const _NavigationList({required this.items});

  final List<NavigationItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const ListTile(
          title: Text('VidiVideo'),
          subtitle: Text('Administration'),
        ),
        const Divider(),
        for (final item in items)
          ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            selected: item.selected,
            onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
          ),
      ],
    );
  }
}
