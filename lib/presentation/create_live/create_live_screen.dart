import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/stream_model.dart';
import '../../core/theme/app_theme.dart';
import 'create_live_controller.dart';

class CreateLiveScreen extends GetView<CreateLiveController> {
  const CreateLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: Get.back,
        ),
        title: const Text('Setup Stream',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.startLive(formKey),
                  child: const Text('Go Live →',
                      style: TextStyle(
                          color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
                ),
              )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platform selector
                const _SectionLabel('Streaming Platform'),
                const SizedBox(height: 10),
                Obx(() => _PlatformSelector(
                      selected: controller.selectedPlatform.value,
                      onSelect: controller.selectPlatform,
                    )),
                const SizedBox(height: 24),

                const _SectionLabel('Stream Details'),
                const SizedBox(height: 10),
                _StreamField(
                  controller: controller.titleController,
                  label: 'Stream Title',
                  hint: 'Give your stream an exciting title',
                  icon: Icons.title_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                _StreamField(
                  controller: controller.descController,
                  label: 'Description (optional)',
                  hint: 'Tell viewers what to expect',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                const _SectionLabel('Agora Channel'),
                const SizedBox(height: 10),
                _StreamField(
                  controller: controller.channelController,
                  label: 'Channel Name',
                  hint: 'Auto-generated unique channel ID',
                  icon: Icons.settings_ethernet_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Channel name required' : null,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.accentColor, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Audience joins via this channel name. Keep it unique.',
                        style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),

                const _SectionLabel('RTMP / CDN Settings'),
                const SizedBox(height: 10),
                _StreamField(
                  controller: controller.rtmpUrlController,
                  label: 'RTMP Server URL',
                  hint: 'rtmp://a.rtmp.youtube.com/live2/',
                  icon: Icons.cloud_upload_rounded,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 14),
                Obx(() => _StreamField(
                      controller: controller.streamKeyController,
                      label: 'Stream Key',
                      hint: 'Paste your stream key here',
                      icon: Icons.vpn_key_rounded,
                      obscureText: !controller.showStreamKey.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showStreamKey.value
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppTheme.textTertiary, size: 18,
                        ),
                        onPressed: controller.toggleShowKey,
                      ),
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.warningColor, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Never share your stream key publicly. It grants full access to your stream.',
                        style: TextStyle(
                            color: AppTheme.warningColor, fontSize: 12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 36),

                // Start Live
                Obx(() => _GradientGoLiveButton(
                      isLoading: controller.isLoading.value,
                      onTap: () => controller.startLive(formKey),
                    )).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Platform Selector ────────────────────────────────────────
class _PlatformSelector extends StatelessWidget {
  final StreamPlatform selected;
  final void Function(StreamPlatform) onSelect;
  const _PlatformSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlatformChip(
          label: '▶ YouTube',
          platform: StreamPlatform.youtube,
          selected: selected,
          color: const Color(0xFFFF0000),
          onTap: () => onSelect(StreamPlatform.youtube),
        ),
        const SizedBox(width: 10),
        _PlatformChip(
          label: 'f Facebook',
          platform: StreamPlatform.facebook,
          selected: selected,
          color: const Color(0xFF1877F2),
          onTap: () => onSelect(StreamPlatform.facebook),
        ),
        const SizedBox(width: 10),
        _PlatformChip(
          label: '⚙ Custom',
          platform: StreamPlatform.custom,
          selected: selected,
          color: AppTheme.secondaryColor,
          onTap: () => onSelect(StreamPlatform.custom),
        ),
      ],
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String label;
  final StreamPlatform platform;
  final StreamPlatform selected;
  final Color color;
  final VoidCallback onTap;
  const _PlatformChip({
    required this.label,
    required this.platform,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  bool get isSelected => selected == platform;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.darkBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      );
}

class _StreamField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _StreamField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
      ),
    );
  }
}

class _GradientGoLiveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _GradientGoLiveButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppTheme.primaryGradient,
          color: isLoading ? AppTheme.darkBorder : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Start Streaming',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}
