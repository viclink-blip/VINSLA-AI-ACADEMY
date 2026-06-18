import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VinslaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const VinslaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading ?? (showBack && Navigator.canPop(context)
        ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))
        : null),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.darkBorder, height: 1),
      ),
    );
  }
}
