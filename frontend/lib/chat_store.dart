// chat_store.dart
// Menyimpan sesi chat dokter secara global (singleton)

import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatSession {
  final String id;
  final String doctorName;
  final String specialty;
  final IconData doctorIcon;
  final List<ChatMessage> messages;
  final DateTime startedAt;

  ChatSession({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.doctorIcon,
    required this.messages,
    required this.startedAt,
  });

  String get lastMessage {
    if (messages.isEmpty) return 'Belum ada pesan';
    return messages.last.text;
  }

  bool get lastIsMe => messages.isNotEmpty && messages.last.isMe;
}

// Global singleton store
class ChatStore {
  ChatStore._();
  static final ChatStore instance = ChatStore._();

  final List<ChatSession> sessions = [];

  void saveSession(ChatSession session) {
    // Update jika sudah ada, tambah jika baru
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      sessions[idx] = session;
    } else {
      sessions.insert(0, session);
    }
  }

  ChatSession? getSession(String id) {
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
