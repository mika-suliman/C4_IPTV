import 'package:another_iptv_player/l10n/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'c4_gradient_placeholder.dart';

class C4Card extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final List<Widget>? badges;
  final bool showProgress;
  final double? progress;
  final ValueChanged<bool>? onFocusChanged;
  final FocusNode? focusNode;

  // New action properties
  final bool? isFavorite;
  final Future<void> Function()? onToggleFavorite;
  final bool? isInWatchLater;
  final Future<void> Function()? onToggleWatchLater;

  const C4Card({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.width,
    this.height,
    this.badges,
    this.showProgress = false,
    this.progress,
    this.onFocusChanged,
    this.focusNode,
    this.isFavorite,
    this.onToggleFavorite,
    this.isInWatchLater,
    this.onToggleWatchLater,
  });

  @override
  State<C4Card> createState() => _C4CardState();
}

class _C4CardState extends State<C4Card> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVOD = (widget.height ?? 1.5) >= (widget.width ?? 1.0);

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
        widget.onFocusChanged?.call(focused);
      },
      onKeyEvent: (node, event) {
        if (_isFocused && event is KeyDownEvent) {
          if (event.logicalKey.debugName == 'Select' || event.logicalKey.debugName == 'Enter') {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isFocused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
              border: Border.all(
                color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image or Placeholder
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const C4GradientPlaceholder(),
                    errorWidget: (context, url, error) => const C4GradientPlaceholder(),
                  )
                else
                  const C4GradientPlaceholder(),

                // Scrim overlay for text readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Badges
                if (widget.badges != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.badges!,
                    ),
                  ),

                // Action Buttons (Top Right, above Badges if both exist)
                if (widget.onToggleFavorite != null || widget.onToggleWatchLater != null)
                  Positioned(
                    top: 8,
                    right: widget.badges != null ? 48.0 : 8.0, // Push left if badges exist
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onToggleWatchLater != null)
                          _CircleIconButton(
                            icon: widget.isInWatchLater == true
                                ? Icons.schedule_rounded
                                : Icons.schedule_outlined,
                            onPressed: () async {
                              // Capture state BEFORE the toggle so the message is correct
                              final wasInWatchLater = widget.isInWatchLater == true;
                              await widget.onToggleWatchLater!();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(wasInWatchLater
                                        ? context.loc.removed_from_watch_later
                                        : context.loc.added_to_watch_later),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    width: 250,
                                  ),
                                );
                              }
                            },
                            active: widget.isInWatchLater == true,
                            activeColor: theme.colorScheme.secondary,
                          ),
                        if (widget.onToggleFavorite != null) ...[
                          const SizedBox(width: 6),
                          _CircleIconButton(
                            icon: widget.isFavorite == true
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            onPressed: () async {
                              // Capture state BEFORE the toggle so the message is correct
                              final wasFavorite = widget.isFavorite == true;
                              await widget.onToggleFavorite!();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(wasFavorite
                                        ? context.loc.removed_from_favorites
                                        : context.loc.added_to_favorites),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    width: 200,
                                  ),
                                );
                              }
                            },
                            active: widget.isFavorite == true,
                            activeColor: Colors.redAccent,
                          ),
                        ],
                      ],
                    ),
                  ),

                // Progress Bar
                if (widget.showProgress && widget.progress != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatefulWidget {
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool active;
  final Color activeColor;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.active = false,
    required this.activeColor,
  });

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _isHovered = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          if (_isLoading) return;
          setState(() => _isLoading = true);
          try {
            await widget.onPressed();
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isLoading
                ? Colors.black.withValues(alpha: 0.3)
                : (_isHovered
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.4)),
            shape: BoxShape.circle,
          ),
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.active ? widget.activeColor : Colors.white,
                    ),
                  ),
                )
              : Icon(
                  widget.icon,
                  size: 18,
                  color: _isHovered
                      ? (widget.active ? widget.activeColor : Colors.black87)
                      : (widget.active ? widget.activeColor : Colors.white),
                ),
        ),
      ),
    );
  }
}
