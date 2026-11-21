
import 'package:mes_taches/modele/due.dart';

enum Priority {
  low,
  normal,
  high
}

class Tache {
  final String id;
  final String title;
  final Priority priority;
  final Due due;
  final String? note;
  final bool done;

  const Tache({
    required this.id,
    required this.title,
    this.priority = Priority.normal,
    this.due = const Due.none(),
    this.note,
    this.done = false,
  });

}