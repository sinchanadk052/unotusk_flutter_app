import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/badges.dart';

class SpecChatDrawer extends StatelessWidget {
  final SpecHistoryItem spec;
  final UnoPalette palette;
  final VoidCallback onClose;

  const SpecChatDrawer({
    super.key,
    required this.spec,
    required this.palette,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final thread = MockData.specChatThreads[spec.id] ??
        [
          {'role': 'user', 'text': spec.query},
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score ${spec.score.toStringAsFixed(2)}] Verified decision and spec context retrieved from repository graph.'
          }
        ];

    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: palette.bgElevated,
        border: Border(left: BorderSide(color: palette.div)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.bgSurface,
              border: Border(bottom: BorderSide(color: palette.div)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        QueryTierBadge(tier: spec.queryType),
                        const SizedBox(width: 6),
                        ConfidenceBadge(tier: spec.confidence),
                        if (spec.hasBDD) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      palette.inferred.withValues(alpha: 0.44)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BDD',
                              style: UnoTypography.mono(
                                color: palette.inferred,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          size: 16, color: palette.textSec),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  spec.query,
                  style: UnoTypography.body(
                    color: palette.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${spec.timestamp} · ${spec.ago}',
                      style: UnoTypography.mono(
                        color: palette.textSec,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Score ${spec.score.toStringAsFixed(2)}',
                      style: UnoTypography.mono(
                        color: palette.textSec,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: thread.length,
              itemBuilder: (context, index) {
                final msg = thread[index];
                final isUser = msg['role'] == 'user';

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'YOU' : 'UNOTUSK',
                        style: UnoTypography.mono(
                          color: isUser ? palette.accent : palette.textSec,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser
                              ? palette.accent.withValues(alpha: 0.12)
                              : palette.bgSurface,
                          border: Border.all(
                            color: isUser
                                ? palette.accent.withValues(alpha: 0.28)
                                : palette.div,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: isUser
                              ? UnoTypography.body(
                                  color: palette.text,
                                  fontSize: 14,
                                )
                              : UnoTypography.mono(
                                  color: palette.text,
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
