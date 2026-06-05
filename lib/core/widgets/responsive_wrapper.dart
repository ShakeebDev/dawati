import 'package:flutter/material.dart';

/// ويدجت مغلف مخصص لتوسيط المحتوى ووضع حد أقصى لعرض الواجهات (مثل النماذج) 
/// على الشاشات الكبيرة (التابلت والويب) لمنع تمدد العناصر بشكل مفرط.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool useScroll;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500.0,
    this.padding = const EdgeInsets.all(24.0),
    this.useScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletOrWeb = size.width > maxWidth + 80;

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (useScroll) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    if (isTabletOrWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
