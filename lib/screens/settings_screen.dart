import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/constants/app_links.dart';
import 'package:finalproject/core/theme/app_theme_controller.dart';
import 'package:finalproject/extensions/app_extensions.dart';
import 'package:finalproject/screens/about_us_screen.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Settings'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _SettingsSectionTitle(title: 'Preferences'),
                const SizedBox(height: 10),
                Material(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _SettingsSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Get alerts for high consumption & leaks',
                        value: _pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _pushNotificationsEnabled = value);
                        },
                      ),
                      const Divider(height: 1),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppThemeController.mode,
                        builder: (context, themeMode, child) {
                          return _SettingsSwitchTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Switch app appearance',
                            value: themeMode == ThemeMode.dark,
                            onChanged: AppThemeController.setDarkMode,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        leading: const _SettingsLeadingIcon(
                          icon: Icons.info_outline_rounded,
                        ),
                        title: const Text(
                          'About Us',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Discover the story behind Smart Loop',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            context.pushScreen<void>(const AboutUsScreen()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ContactFooter(
            onTikTokPressed: () =>
                _openSocialLink(name: 'TikTok', url: AppLinks.tiktok),
            onInstagramPressed: () =>
                _openSocialLink(name: 'Instagram', url: AppLinks.instagram),
            onXPressed: () => _openSocialLink(name: 'X', url: AppLinks.x),
          ),
        ],
      ),
    );
  }

  Future<void> _openSocialLink({
    required String name,
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _showLinkMessage('$name account link will be added soon.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showLinkMessage('Could not open the $name account.');
      }
    } on Exception {
      _showLinkMessage('Could not open the $name account.');
    }
  }

  void _showLinkMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _SettingsLeadingIcon extends StatelessWidget {
  const _SettingsLeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: AppColors.primaryAccent),
    );
  }
}

class _ContactFooter extends StatelessWidget {
  const _ContactFooter({
    required this.onTikTokPressed,
    required this.onInstagramPressed,
    required this.onXPressed,
  });

  final VoidCallback onTikTokPressed;
  final VoidCallback onInstagramPressed;
  final VoidCallback onXPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final footerColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Material(
      color: colorScheme.surface,
      elevation: 10,
      shadowColor: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  tooltip: 'TikTok',
                  icon: FontAwesomeIcons.tiktok,
                  onPressed: onTikTokPressed,
                ),
                const SizedBox(width: 18),
                _SocialButton(
                  tooltip: 'Instagram',
                  icon: FontAwesomeIcons.instagram,
                  onPressed: onInstagramPressed,
                ),
                const SizedBox(width: 18),
                _SocialButton(
                  tooltip: 'X',
                  icon: FontAwesomeIcons.xTwitter,
                  onPressed: onXPressed,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(
                    color: footerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: AppColors.primaryAccent.withValues(alpha: 0.55),
                ),
                Text(
                  ' by Mohammed & Abdulilah',
                  style: TextStyle(
                    color: footerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final FaIconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.12),
          foregroundColor: AppColors.primaryAccent,
          fixedSize: const Size(50, 50),
        ),
        icon: FaIcon(icon, size: 21),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _SettingsLeadingIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      value: value,
      activeThumbColor: AppColors.primaryAccent,
      activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.45),
      inactiveThumbColor: AppColors.primaryAccent.withValues(alpha: 0.55),
      inactiveTrackColor: AppColors.primaryAccent.withValues(alpha: 0.15),
      onChanged: onChanged,
    );
  }
}
