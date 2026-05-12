import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/split_session.dart';
import '../providers/history_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/profile_sheet.dart';

// ── Stagger timing constants ─────────────────────────────────────────────────
const _d0 = Duration(milliseconds: 0);
const _d1 = Duration(milliseconds: 130);
const _d2 = Duration(milliseconds: 230);
const _d3 = Duration(milliseconds: 330);
const _d4 = Duration(milliseconds: 430);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyNotifierProvider);
    final profile = ref.watch(profileNotifierProvider);

    // Active session = most-recent unsettled session (if any)
    final SplitSession? activeSession = history
        .where((s) => !s.isSettled)
        .fold<SplitSession?>(null, (prev, s) => prev == null ? s : s);

    // Previous settled session
    final SplitSession? previousSession = history
        .where((s) => s.isSettled)
        .firstOrNull;

    // Deduplicated people across all sessions for "Recently Split" row
    final recentPeople = <String, String>{}; // id → emoji/name
    for (final s in history.take(5)) {
      for (final p in s.participants) {
        recentPeople[p.id] = p.avatarEmoji ?? p.name[0].toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),

            // ── TOP BAR ──────────────────────────────────────────────────────
            FadeSlide(
              delay: _d0,
              child: _TopBar(
                profile: profile,
                onAvatarTap: () => _openProfile(context),
              ),
            ),

            const SizedBox(height: 28),

            // ── ACTIVE BILL CARD ─────────────────────────────────────────────
            FadeSlide(
              delay: _d1,
              child: _ActiveBillCard(
                session: activeSession,
                onSplitNow: () => context.push('/split'),
              ),
            ),

            const SizedBox(height: 16),

            // ── PREVIOUS SPLIT CARD ──────────────────────────────────────────
            if (previousSession != null) ...[
              FadeSlide(
                delay: _d2,
                child: _PreviousSplitCard(
                  session: previousSession,
                  onTap: () => context.push('/history'),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── NEARBY FRIENDS SECTION ───────────────────────────────────────
            FadeSlide(
              delay: _d3,
              child: _NearbyFriendsSection(history: history),
            ),

            const SizedBox(height: 24),

            // ── RECENTLY SPLIT SECTION ───────────────────────────────────────
            if (recentPeople.isNotEmpty)
              FadeSlide(
                delay: _d4,
                child: _RecentlySplitSection(history: history),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // FAB → quick new split
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/split'),
        backgroundColor: AppTheme.accentWarm,
        foregroundColor: AppTheme.primaryBg,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Split',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onAvatarTap;

  const _TopBar({required this.profile, required this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App title block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ploy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Bill Splitter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Avatar button
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentButton.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentWarm, width: 2),
            ),
            child: Center(
              child: Text(profile.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Active Bill Card ─────────────────────────────────────────────────────────

class _ActiveBillCard extends StatelessWidget {
  final SplitSession? session;
  final VoidCallback onSplitNow;

  const _ActiveBillCard({required this.session, required this.onSplitNow});

  @override
  Widget build(BuildContext context) {
    final amount = session?.totalAmount ?? 0.0;
    final participants = session?.participants ?? [];
    final hasSession = session != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.accentWarm,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Bill',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryBg.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasSession ? '₹${amount.toStringAsFixed(2)}' : '₹0.00',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryBg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasSession) ...[
                      const SizedBox(height: 4),
                      Text(
                        session!.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBg.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Stacked avatars
              if (participants.isNotEmpty)
                _StackedAvatars(participants: participants.take(4).toList()),
            ],
          ),

          const SizedBox(height: 20),

          // Split Now button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSplitNow,
              icon: const Icon(Icons.call_split_rounded, size: 18),
              label: Text(hasSession ? 'Continue Split' : 'Split Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBg,
                foregroundColor: AppTheme.accentWarm,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stacked Overlapping Avatars ───────────────────────────────────────────────

class _StackedAvatars extends StatelessWidget {
  final List participants;
  const _StackedAvatars({required this.participants});

  @override
  Widget build(BuildContext context) {
    const double size = 38;
    const double overlap = 14;

    return SizedBox(
      height: size,
      width: size + (participants.length - 1) * (size - overlap),
      child: Stack(
        children: List.generate(participants.length, (i) {
          final p = participants[i];
          final colors = [
            Colors.pinkAccent,
            Colors.cyanAccent,
            Colors.deepPurpleAccent,
            Colors.orangeAccent,
          ];
          return Positioned(
            left: i * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors[i % colors.length].withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentWarm, width: 2),
              ),
              child: Center(
                child: Text(
                  p.avatarEmoji ?? p.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Previous Split Card ──────────────────────────────────────────────────────

class _PreviousSplitCard extends StatelessWidget {
  final SplitSession session;
  final VoidCallback onTap;
  const _PreviousSplitCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentButton.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppTheme.accentWarm,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your previous split',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Text(
              '₹${session.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.accentWarm,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Nearby Friends Section ───────────────────────────────────────────────────

class _NearbyFriendsSection extends StatelessWidget {
  final List<SplitSession> history;
  const _NearbyFriendsSection({required this.history});

  @override
  Widget build(BuildContext context) {
    // Gather unique people from all sessions
    final seen = <String>{};
    final people = <dynamic>[];
    for (final s in history) {
      for (final p in s.participants) {
        if (seen.add(p.id)) people.add(p);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Nearby Friends',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/history'),
              child: Text(
                'See all',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentWarm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (people.isEmpty)
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Center(
              child: Text(
                'Start a split to see people here',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = people[i];
                return _FriendChip(
                  name: p.name as String,
                  emoji: p.avatarEmoji as String? ?? '',
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FriendChip extends StatelessWidget {
  final String name;
  final String emoji;
  const _FriendChip({required this.name, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
    ];
    final color = colors[name.length % colors.length];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              emoji.isNotEmpty ? emoji : name[0].toUpperCase(),
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 54,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ── Recently Split Section ───────────────────────────────────────────────────

class _RecentlySplitSection extends StatelessWidget {
  final List<SplitSession> history;
  const _RecentlySplitSection({required this.history});

  @override
  Widget build(BuildContext context) {
    // Unique people across recent sessions
    final seen = <String>{};
    final people = <dynamic>[];
    for (final s in history.take(6)) {
      for (final p in s.participants) {
        if (seen.add(p.id)) people.add(p);
      }
    }

    if (people.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Split With',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final p = people[i];
              return _FriendChip(
                name: p.name as String,
                emoji: p.avatarEmoji as String? ?? '',
              );
            },
          ),
        ),
      ],
    );
  }
}
