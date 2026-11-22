import 'package:mes_taches/modele/echeance.dart';

enum Priority { low, normal, high }

class Tache {
  final String id;
  final String title;
  final Priority priority;
  final Echeance due;
  final String? note;
  final bool done;

  const Tache({
    required this.id,
    required this.title,
    this.priority = Priority.normal,
    this.due = const Echeance.none(),
    this.note,
    this.done = false,
  });

  Tache copyWith({
    String? titre,
    Priority? priorite,
    Echeance? echeance,
    String? note,
    bool? faite,
    bool effacerNote = false,
  }) {
    return Tache(
      id: id, // l'id ne change jamais
      title: titre ?? title,
      priority: priorite ?? priority,
      due: echeance ?? due,
      note: effacerNote ? null : (note ?? this.note),
      done: faite ?? done,
    );
  }
}
