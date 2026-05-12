import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/masjid.dart';
import '../../../data/providers/repository_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/search-results-nearby.html`.
///
/// Live-filters against [MasjidRepository.search] as the user types.
/// "Recent" chips are local-only for now; B-phase persists them in
/// SharedPreferences and surfaces them via a provider.
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final _controller = TextEditingController(text: 'al-ab');
  final _focusNode = FocusNode();
  // Local recent-search list — moves to SharedPreferences in B-phase.
  final _recentSearches = <String>['Masjid Al-Abrar', 'Masjid de Paris'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameNearbyMasjids);
    }
  }

  void _useRecent(String label) {
    _controller.text = label;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: label.length),
    );
    _focusNode.requestFocus();
  }

  void _removeRecent(String label) {
    setState(() => _recentSearches.remove(label));
  }

  void _selectMasjid(String id) {
    final query = _controller.text.trim();
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() => _recentSearches.insert(0, query));
    }
    context.goNamed(
      ListenerRoute.nameMasjidDetail,
      pathParameters: <String, String>{'masjidId': id},
    );
  }

  void _searchGlobally() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Global masjid search across all regions arrives in B2.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final repo = ref.watch(masjidRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _SearchHeader(
                  controller: _controller,
                  focusNode: _focusNode,
                  onCancel: _cancel,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.containerMargin,
                      AppSpacing.gutter,
                      AppSpacing.containerMargin,
                      140,
                    ),
                    children: <Widget>[
                      if (_recentSearches.isNotEmpty) ...<Widget>[
                        Text(
                          'RECENT',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.inkMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final r in _recentSearches)
                              _RecentChip(
                                label: r,
                                onTap: () => _useRecent(r),
                                onRemove: () => _removeRecent(r),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],
                      // Results block — async future, filters refresh per query
                      FutureBuilder<List<Masjid>>(
                        future: query.isEmpty
                            ? repo.getNearby(
                                latitude: 52.4862,
                                longitude: -1.8904,
                              )
                            : repo.search(query),
                        builder: (context, snap) {
                          final results = snap.data ?? const <Masjid>[];
                          final isLoading =
                              snap.connectionState == ConnectionState.waiting;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    query.isEmpty
                                        ? 'NEARBY · ${results.length} MASJIDS'
                                        : 'RESULTS · ${results.length} ${results.length == 1 ? "MATCH" : "MATCHES"}',
                                    style:
                                        AppTypography.labelCaps.copyWith(
                                      color: AppColors.inkMuted,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (isLoading)
                                const _ResultsSkeleton()
                              else if (results.isEmpty)
                                _NoResults(query: query)
                              else
                                Column(
                                  children: <Widget>[
                                    for (var i = 0; i < results.length; i++)
                                      ...<Widget>[
                                        if (i > 0) const SizedBox(height: 12),
                                        _ResultCard(
                                          masjid: results[i],
                                          query: query,
                                          onTap: () =>
                                              _selectMasjid(results[i].id),
                                        ),
                                      ],
                                  ],
                                ),
                              if (query.isNotEmpty) ...<Widget>[
                                const SizedBox(height: AppSpacing.sectionGap),
                                _GlobalSearchButton(
                                  query: query,
                                  onTap: _searchGlobally,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameSearchResults,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search header — sticky input + Cancel
// ─────────────────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onCancel,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeepNight.withValues(alpha: 0.85),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        24,
        AppSpacing.containerMargin,
        16,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: AppRadii.xlAll,
                border: Border.all(color: AppColors.borderMedium),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Symbols.search_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      cursorColor: AppColors.primary,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Search masjids',
                        hintStyle: AppTypography.bodyLg.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        controller.clear();
                        focusNode.requestFocus();
                      },
                      child: const Icon(
                        Symbols.close_rounded,
                        color: AppColors.inkMuted,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            borderRadius: AppRadii.lgAll,
            child: InkWell(
              onTap: onCancel,
              borderRadius: AppRadii.lgAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Text(
                  'Cancel',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent search chips
// ─────────────────────────────────────────────────────────────────────────────

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgElevated,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: const Icon(
                  Symbols.close_rounded,
                  color: AppColors.inkMuted,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result card — masjid row with gold-highlighted match
// ─────────────────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.masjid,
    required this.query,
    required this.onTap,
  });
  final Masjid masjid;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.heroAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: AppSpacing.cardInner,
          decoration: BoxDecoration(
            borderRadius: AppRadii.heroAll,
            border: Border.all(
              color: AppColors.inkPrimary.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgDeepNight,
                  border: Border.all(
                    color: AppColors.outlineVariant,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Symbols.mosque_rounded,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: 22,
                  fill: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: _HighlightedText(
                            text: masjid.name,
                            query: query,
                          ),
                        ),
                        if (masjid.isVerified) ...<Widget>[
                          const SizedBox(width: 6),
                          const Icon(
                            Symbols.verified_rounded,
                            color: AppColors.goldHighlight,
                            size: 16,
                            fill: 1,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        if (masjid.distanceKm != null) ...<Widget>[
                          Text(
                            _formatDistance(masjid.distanceKm!),
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.inkMuted.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            masjid.city,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Symbols.chevron_right_rounded,
                color: AppColors.inkMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    if (km < 100) return '${km.toStringAsFixed(0)} km';
    return '${(km / 1000).toStringAsFixed(0)}k km';
  }
}

/// Renders [text] with substrings matching [query] highlighted in gold.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.query});
  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: AppTypography.bodyLg.copyWith(color: AppColors.inkPrimary),
        overflow: TextOverflow.ellipsis,
      );
    }
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    var cursor = 0;
    while (cursor < text.length) {
      final idx = lowerText.indexOf(lowerQuery, cursor);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }
      if (idx > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      cursor = idx + query.length;
    }
    return Text.rich(
      TextSpan(
        style: AppTypography.bodyLg.copyWith(color: AppColors.inkPrimary),
        children: spans,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state + skeleton + global-search button
// ─────────────────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Symbols.travel_explore_rounded,
            color: AppColors.inkMuted,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No masjids match “$query” in your area.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < 3; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: AppRadii.heroAll,
              color: AppColors.surfaceCard.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlobalSearchButton extends StatelessWidget {
  const _GlobalSearchButton({required this.query, required this.onTap});
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Search globally for '$query'",
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Symbols.arrow_forward_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
