import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OntologyGraphScreen extends StatefulWidget {
  final UnoPalette palette;

  const OntologyGraphScreen({super.key, required this.palette});

  @override
  State<OntologyGraphScreen> createState() => _OntologyGraphScreenState();
}

class _OntologyGraphScreenState extends State<OntologyGraphScreen> {
  int? _hoveredNodeId;
  List<OntologyNode> _nodes = [];
  List<List<int>> _edges = [];

  @override
  void initState() {
    super.initState();
    _loadOntology();
  }

  void _loadOntology() async {
    final nodes = await ApiService.fetchOntologyNodes();
    final edges = await ApiService.fetchOntologyEdges();
    if (mounted) {
      setState(() {
        _nodes = nodes;
        _edges = edges;
      });
    }
  }

  Color _getNodeColor(String type) {
    switch (type) {
      case 'Service':
        return UnoPalette.entityService;
      case 'Decision':
        return UnoPalette.entityDecision;
      case 'Commit':
        return UnoPalette.entityCommit;
      case 'Ticket':
        return UnoPalette.entityTicket;
      case 'Thread':
        return UnoPalette.entityThread;
      case 'Person':
      default:
        return UnoPalette.entityPerson;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'ONTOLOGY GRAPH',
                style: UnoTypography.mono(
                  color: widget.palette.textSec,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Knowledge Graph',
                style: UnoTypography.brandSerif(
                  palette: widget.palette,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Entity relationships indexed across commits, tickets, threads, and decisions.',
                style: UnoTypography.body(
                  color: widget.palette.textSec,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Interactive SVG / Canvas Graph Container
              Container(
                height: 480,
                decoration: BoxDecoration(
                  color: widget.palette.bgSurface,
                  border: Border.all(color: widget.palette.div),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scaleX = constraints.maxWidth / 840.0;
                    final scaleY = constraints.maxHeight / 460.0;
                    final scale = scaleX < scaleY ? scaleX : scaleY;

                    return GestureDetector(
                      onTapUp: (details) {
                        // find tapped node
                        int? tappedId;
                        for (final node in _nodes) {
                          final nx = node.cx * scale;
                          final ny = node.cy * scale;
                          final distSq = (details.localPosition.dx - nx) *
                                  (details.localPosition.dx - nx) +
                              (details.localPosition.dy - ny) *
                                  (details.localPosition.dy - ny);
                          if (distSq < 400) {
                            tappedId = node.id;
                            break;
                          }
                        }
                        setState(() {
                          _hoveredNodeId =
                              _hoveredNodeId == tappedId ? null : tappedId;
                        });
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _OntologyGraphPainter(
                          nodes: _nodes,
                          edges: _edges,
                          hoveredNodeId: _hoveredNodeId,
                          palette: widget.palette,
                          scale: scale,
                          getNodeColor: _getNodeColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Legend
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  'Service',
                  'Decision',
                  'Commit',
                  'Ticket',
                  'Thread',
                  'Person'
                ].map((type) {
                  final color = _getNodeColor(type);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type.toUpperCase(),
                        style: UnoTypography.mono(
                          color: widget.palette.textSec,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              if (_hoveredNodeId != null) ...[
                const SizedBox(height: 20),
                _buildNodeDetailsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeDetailsCard() {
    if (_nodes.isEmpty) return const SizedBox();
    final node = _nodes.firstWhere(
      (n) => n.id == _hoveredNodeId,
      orElse: () => _nodes.first,
    );
    final connectedEdges = _edges
        .where((e) => e[0] == node.id || e[1] == node.id)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.bgElevated,
        border: Border.all(color: widget.palette.accent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _getNodeColor(node.type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                node.label,
                style: UnoTypography.body(
                  color: widget.palette.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getNodeColor(node.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  node.type.toUpperCase(),
                  style: UnoTypography.mono(
                    color: _getNodeColor(node.type),
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '$connectedEdges active relationships',
            style: UnoTypography.mono(
              color: widget.palette.textSec,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _OntologyGraphPainter extends CustomPainter {
  final List<OntologyNode> nodes;
  final List<List<int>> edges;
  final int? hoveredNodeId;
  final UnoPalette palette;
  final double scale;
  final Color Function(String) getNodeColor;

  _OntologyGraphPainter({
    required this.nodes,
    required this.edges,
    required this.hoveredNodeId,
    required this.palette,
    required this.scale,
    required this.getNodeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center the graph
    final offsetX = (size.width - 840 * scale) / 2;
    final offsetY = (size.height - 460 * scale) / 2;

    // Draw Edges
    for (final edge in edges) {
      final from = nodes[edge[0]];
      final to = nodes[edge[1]];

      final isHighlight = hoveredNodeId == from.id || hoveredNodeId == to.id;

      final paint = Paint()
        ..color = isHighlight
            ? palette.accent.withValues(alpha: 0.8)
            : palette.div.withValues(alpha: 0.45)
        ..strokeWidth = isHighlight ? 1.8 : 1.0
        ..style = PaintingStyle.stroke;

      final p1 = Offset(from.cx * scale + offsetX, from.cy * scale + offsetY);
      final p2 = Offset(to.cx * scale + offsetX, to.cy * scale + offsetY);

      canvas.drawLine(p1, p2, paint);
    }

    // Draw Nodes
    for (final node in nodes) {
      final isHovered = hoveredNodeId == node.id;
      final nodeColor = getNodeColor(node.type);
      final center =
          Offset(node.cx * scale + offsetX, node.cy * scale + offsetY);
      final radius = isHovered ? 10.0 : 7.0;

      // Glow when hovered
      if (isHovered) {
        final glowPaint = Paint()
          ..color = nodeColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(center, radius + 4, glowPaint);
      }

      // Node background
      final fillPaint = Paint()
        ..color = isHovered ? nodeColor : palette.bgElevated
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);

      // Node border
      final strokePaint = Paint()
        ..color = nodeColor
        ..strokeWidth = isHovered ? 2.2 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, strokePaint);

      // Node Label
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9,
          color: isHovered ? palette.text : palette.textSec,
          fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OntologyGraphPainter oldDelegate) {
    return oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.palette != palette ||
        oldDelegate.scale != scale;
  }
}
