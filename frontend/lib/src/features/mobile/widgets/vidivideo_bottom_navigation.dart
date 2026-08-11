import 'package:flutter/material.dart';

class VidiVideoBottomNavigation extends StatelessWidget {
  const VidiVideoBottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Color(0xFF1F1F1F),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationIcon(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                isSelected: selectedIndex == 0,
                onPressed: () => onItemSelected(0),
              ),
              _NavigationIcon(
                icon: Icons.search,
                selectedIcon: Icons.search,
                isSelected: selectedIndex == 1,
                onPressed: () => onItemSelected(1),
              ),

              _CreateButton(
                isSelected: selectedIndex == 2,
                onPressed: () => onItemSelected(2),
              ),

              _NavigationIcon(
                icon: Icons.workspace_premium_outlined,
                selectedIcon: Icons.workspace_premium,
                isSelected: selectedIndex == 3,
                onPressed: () => onItemSelected(3),
              ),
              _NavigationIcon(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                isSelected: selectedIndex == 4,
                onPressed: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: 23,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.isSelected,
    required this.onPressed,
  });

  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        onTap: onPressed,
        radius: 32,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isSelected ? 42 : 38,
            height: isSelected ? 42 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D95),
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF2D95),
                  Color(0xFFEE4D8B),
                ],
              ),
              boxShadow: isSelected ?
              [
                      BoxShadow(
                        color: const Color(0x66FF2D95),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
              ]
              : 
              [
                BoxShadow(
                  color: const Color(0xffFE2C55).withValues(alpha: .45),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xff25F4EE).withValues(alpha: .35),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}