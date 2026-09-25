import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String org;
  final String email;
  final String role;

  const UserModel({
    required this.name,
    required this.org,
    this.email = 'naren@unotusk.com',
    this.role = 'Staff Engineer / Tech Lead',
  });
}

class NotificationItem {
  final String id;
  final String type; // success, info, warning, error
  final String title;
  final String body;
  final String time;
  bool read;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
  });
}

class ProjectItem {
  final String id;
  final String name;
  final String upsStatus; // active, offline
  final String ingestionStatus; // live, stale, ingesting
  final String lastIngestion;
  final double fpr;
  final int days;

  const ProjectItem({
    required this.id,
    required this.name,
    required this.upsStatus,
    required this.ingestionStatus,
    required this.lastIngestion,
    required this.fpr,
    required this.days,
  });
}

class ActivityItem {
  final String id;
  final String icon;
  final String text;
  final String time;
  final Color color;

  const ActivityItem({
    required this.id,
    required this.icon,
    required this.text,
    required this.time,
    required this.color,
  });
}

class RecentChat {
  final int id;
  final String title;
  final String ago;
  final String time;

  const RecentChat({
    required this.id,
    required this.title,
    required this.ago,
    required this.time,
  });
}

class ArchivedChat {
  final int id;
  final String title;
  final String date;
  final int messages;

  const ArchivedChat({
    required this.id,
    required this.title,
    required this.date,
    required this.messages,
  });
}

class SpecHistoryItem {
  final String id;
  final String query;
  final String timestamp;
  final String ago;
  final String isoDate;
  final String queryType; // cold, warm, hot
  final String confidence; // confirmed, uncertain, insufficient
  final double score;
  final double? fprDelta;
  final bool hasBDD;

  const SpecHistoryItem({
    required this.id,
    required this.query,
    required this.timestamp,
    required this.ago,
    required this.isoDate,
    required this.queryType,
    required this.confidence,
    required this.score,
    this.fprDelta,
    required this.hasBDD,
  });
}

class ResponseSegment {
  final String text;
  final String? tag; // CONFIRMED, INFERRED
  final String? note;

  const ResponseSegment({
    required this.text,
    this.tag,
    this.note,
  });
}

class ScoreComponent {
  final String label;
  final double score;

  const ScoreComponent({required this.label, required this.score});
}

class ReasoningModel {
  final double compositeScore;
  final List<ScoreComponent> components;
  final List<String> routingPath;
  final List<String> ontologyEdges;
  final List<String> citations;

  const ReasoningModel({
    required this.compositeScore,
    required this.components,
    required this.routingPath,
    required this.ontologyEdges,
    required this.citations,
  });
}

class TestCase {
  final int id;
  final String desc;

  const TestCase({required this.id, required this.desc});
}

class RiskItem {
  final String tag;
  final String text;

  const RiskItem({required this.tag, required this.text});
}

class BddSpec {
  final String given;
  final String when;
  final String then;
  final String kpi;
  final String kpiTag;
  final String? kpiNote;
  final List<TestCase> testCases;
  final List<RiskItem> risks;

  const BddSpec({
    required this.given,
    required this.when,
    required this.then,
    required this.kpi,
    required this.kpiTag,
    this.kpiNote,
    required this.testCases,
    required this.risks,
  });
}

class QueryResponseData {
  final List<ResponseSegment> segments;
  final String meta;
  final String queryType;
  final String confidence;
  final ReasoningModel? reasoning;
  final BddSpec? bdd;

  const QueryResponseData({
    required this.segments,
    required this.meta,
    required this.queryType,
    required this.confidence,
    this.reasoning,
    this.bdd,
  });
}

enum MessageKind { query, generating, response }

class ChatMessage {
  final String id;
  final MessageKind kind;
  final String? text;
  final String? phase; // ingesting, scoring, deepScoring
  final QueryResponseData? data;

  const ChatMessage({
    required this.id,
    required this.kind,
    this.text,
    this.phase,
    this.data,
  });

  ChatMessage copyWith({
    String? id,
    MessageKind? kind,
    String? text,
    String? phase,
    QueryResponseData? data,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      phase: phase ?? this.phase,
      data: data ?? this.data,
    );
  }
}

class OntologyNode {
  final int id;
  final double cx;
  final double cy;
  final String label;
  final String type; // Service, Decision, Commit, Ticket, Thread, Person

  const OntologyNode({
    required this.id,
    required this.cx,
    required this.cy,
    required this.label,
    required this.type,
  });
}

class HeroCardItem {
  final String title;
  final String tag;
  final IconData icon;

  const HeroCardItem({
    required this.title,
    required this.tag,
    required this.icon,
  });
}
