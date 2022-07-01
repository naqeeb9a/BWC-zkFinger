import 'package:fpzk/utils/app_routes.dart';
import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget with PreferredSizeWidget {
  final Color backgroundColor;
  final String title;
  final AppBar appBar;
  final bool automaticallyImplyLeading, centerTitle;
  final List<Widget> widgets;
  final double appBarHeight;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  /// you can add more fields that meet your needs

  const BaseAppBar(
      {Key? key,
      required this.title,
      required this.appBar,
      required this.widgets,
      this.automaticallyImplyLeading = false,
      this.backgroundColor = Colors.transparent,
      this.centerTitle = true,
      required this.appBarHeight,
      this.bottom,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: true,
        leading: automaticallyImplyLeading == false
            ? null
            : leading ??
                InkWell(
                  onTap: () => KRoutes.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
        actions: widgets,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
