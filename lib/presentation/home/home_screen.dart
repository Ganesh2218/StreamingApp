import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/stream_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/widgets/live_badge.dart';
import '../../core/widgets/viewer_count_widget.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.darkCard,
          onRefresh: controller.loadStreams,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              _buildSearchBar(),
              _buildFeaturedSection(context),
              _buildLiveSectionHeader(context),
              _buildStreamGrid(context),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isHost) return const SizedBox.shrink();
        return _GoLiveFab(onTap: controller.navigateToCreateLive);
      }),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            // Logo
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.live_tv_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text('LiveHub',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
            const Spacer(),
            Obx(() => _AvatarButton(
                  name: controller.currentUser.value?.name ?? 'User',
                  onTap: () => _showProfileSheet(context),
                )),
          ],
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: TextField(
          onChanged: controller.onSearchChanged,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search streams, creators…',
            hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppTheme.textTertiary, size: 20),
            filled: true,
            fillColor: AppTheme.darkCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          ),
        ),
      ).animate().fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400)),
    );
  }

  // ─── Featured Section ────────────────────────────────────────
  Widget _buildFeaturedSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final featured = controller.featuredStreams;
        if (featured.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                const _SectionPulse(),
                const SizedBox(width: 8),
                Text('Featured',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _FeaturedCard(
                  stream: featured[i],
                  onTap: () => controller.navigateToAudienceLive(featured[i]),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  // ─── Live Section Header ─────────────────────────────────────
  Widget _buildLiveSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                const LiveBadge(),
                const SizedBox(width: 8),
                Text('Live Now',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${controller.filteredStreams.length} streams',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.textTertiary)),
              ],
            ),
          )),
    );
  }

  // ─── Stream Grid ─────────────────────────────────────────────
  Widget _buildStreamGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          ),
        );
      }
      if (controller.filteredStreams.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyState());
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final s = controller.filteredStreams[i];
              return _StreamCard(
                stream: s,
                index: i,
                onTap: () => controller.navigateToAudienceLive(s),
              );
            },
            childCount: controller.filteredStreams.length,
          ),
        ),
      );
    });
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.darkBorder,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Obx(() => Text(
                  controller.currentUser.value?.name ?? '',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                )),
            const SizedBox(height: 4),
            Obx(() => Text(
                  controller.currentUser.value?.email ?? '',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14),
                )),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    controller.isHost ? '🎙 Host' : '👁 Viewer',
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                )),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.logout();
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Featured Card ────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final StreamModel stream;
  final VoidCallback onTap;
  const _FeaturedCard({required this.stream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const [Color(0xFF1A0533), Color(0xFF3D0D6B)],
      const [Color(0xFF001A33), Color(0xFF003366)],
      const [Color(0xFF1A0A00), Color(0xFF4D1F00)],
      const [Color(0xFF001A0A), Color(0xFF00331A)],
    ];
    final grad = colors[stream.hostId.hashCode % colors.length];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: grad,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Color(0xCC000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LiveBadge(),
                const Spacer(),
                Text(stream.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person_rounded,
                      color: AppTheme.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(stream.hostName,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const Spacer(),
                  ViewerCountWidget(count: stream.viewerCount),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Stream Grid Card ─────────────────────────────────────────
class _StreamCard extends StatelessWidget {
  final StreamModel stream;
  final int index;
  final VoidCallback onTap;
  const _StreamCard(
      {required this.stream, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xFF1A0533), const Color(0xFF6C2BD9)],
      [const Color(0xFF001233), const Color(0xFF0044CC)],
      [const Color(0xFF1A0800), const Color(0xFFCC4400)],
      [const Color(0xFF001A0A), const Color(0xFF006633)],
      [const Color(0xFF1A1500), const Color(0xFFCC9900)],
      [const Color(0xFF1A001A), const Color(0xFF990099)],
    ];
    final grad = gradients[index % gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: grad,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.darkBorder, width: 0.5),
        ),
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Color(0xEE000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const LiveBadge(compact: true),
                  const Spacer(),
                  ViewerCountWidget(count: stream.viewerCount, compact: true),
                ]),
                const Spacer(),
                // Avatar + Name
                Row(children: [
                  _HostAvatar(name: stream.hostName, size: 24),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(stream.hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(stream.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.3)),
              ],
            ),
          ),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.08);
  }
}

// ─── Supporting Widgets ───────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _AvatarButton({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

class _HostAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _HostAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.purpleGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'H',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.45)),
    );
  }
}

class _GoLiveFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GoLiveFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Go Live',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ]),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
        duration: const Duration(seconds: 2), color: Colors.white.withOpacity(0.15));
  }
}

class _SectionPulse extends StatelessWidget {
  const _SectionPulse();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
          color: AppTheme.liveRedColor, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).fadeIn().then().fadeOut(duration: const Duration(milliseconds: 800));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(children: [
        const Icon(Icons.live_tv_outlined, color: AppTheme.textTertiary, size: 64),
        const SizedBox(height: 16),
        Text('No streams found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                )),
        const SizedBox(height: 8),
        Text('Try a different search term',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                )),
      ]),
    );
  }
}
