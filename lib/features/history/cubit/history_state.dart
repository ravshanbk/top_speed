import '../../../core/models/session.dart';

class HistoryState {
  final List<Session> sessions;

  const HistoryState({required this.sessions});

  factory HistoryState.initial() => const HistoryState(sessions: []);
}
