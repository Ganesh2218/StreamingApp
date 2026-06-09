import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import 'auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // ── Gradient background ───────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0A1F), Color(0xFF12082E), Color(0xFF0A0A1F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // ── Glow orb ─────────────────────────────────────
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.live_tv_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'LiveHub',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideX(begin: -0.1),
                    const SizedBox(height: 48),
                    Text(
                      'Join the\nStream.',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600)).slideY(begin: 0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Go live or watch the world — your choice.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600)),
                    const SizedBox(height: 48),
                    // Name field
                    _buildInputField(
                      controller: nameCtrl,
                      label: 'Display Name',
                      hint: 'How should we call you?',
                      icon: Icons.person_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500)),
                    const SizedBox(height: 16),
                    // Email field
                    _buildInputField(
                      controller: emailCtrl,
                      label: 'Email',
                      hint: 'your@email.com',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!GetUtils.isEmail(v)) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: const Duration(milliseconds: 350), duration: const Duration(milliseconds: 500)),
                    const SizedBox(height: 28),
                    // Role selection
                    Text(
                      'I want to…',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                role: UserRole.audience,
                                title: 'Watch',
                                subtitle: 'Discover & enjoy streams',
                                icon: Icons.play_circle_fill_rounded,
                                isSelected: controller.selectedRole.value ==
                                    UserRole.audience,
                                onTap: () => controller.selectRole(UserRole.audience),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                role: UserRole.host,
                                title: 'Go Live',
                                subtitle: 'Broadcast to the world',
                                icon: Icons.videocam_rounded,
                                isSelected: controller.selectedRole.value ==
                                    UserRole.host,
                                onTap: () => controller.selectRole(UserRole.host),
                              ),
                            ),
                          ],
                        )).animate().fadeIn(delay: const Duration(milliseconds: 450)),
                    const SizedBox(height: 36),
                    // Login button
                    Obx(() => _GradientButton(
                          label: controller.isLoading.value
                              ? 'Joining…'
                              : 'Enter LiveHub',
                          isLoading: controller.isLoading.value,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              controller.login(nameCtrl.text, emailCtrl.text);
                            }
                          },
                        )).animate().fadeIn(delay: const Duration(milliseconds: 500)).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'By continuing you agree to our Terms of Service\nand Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
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

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animDurationFast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
                size: 28),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                )),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary,
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : AppTheme.primaryGradient,
          color: isLoading ? AppTheme.darkBorder : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
