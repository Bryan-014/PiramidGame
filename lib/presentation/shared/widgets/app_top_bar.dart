import 'package:flutter/material.dart';

import '../app_design.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.leadingIcon,
    required this.onLeadingTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData leadingIcon;
  final VoidCallback onLeadingTap;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      leadingWidth: 64,
      leading: Center(
        child: _RoundHeaderButton(icon: leadingIcon, onTap: onLeadingTap),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(.22)),
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: trailing == null
          ? null
          : [Padding(padding: const EdgeInsets.only(right: 12), child: trailing!)],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = _RoundHeaderButton(icon: icon, onTap: onTap);
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
