import 'echeance.dart';
import 'tache.dart';

Priority? prioriteDepuisCode(String code) {
  switch (code) {
    case 'low':
      return Priority.low;
    case 'normal':
      return Priority.normal;
    case 'high':
      return Priority.high;
    default:
      return null;
  }
}

Tache tacheDepuisJson(Map<String, Object?> json) {
  final id = json['id'];
  final title = json['title'];
  final priorityCode = json['priority'];
  final noteBrute = json['note'];
  final due = json['due'];
  final done = json['done'];

  if (id is! String || id.trim().isEmpty) {
    throw FormatException('id invalide');
  }
  if (title is! String || title.trim().isEmpty) {
    throw FormatException('title invalide');
  }
  if (done is! bool) {
    throw FormatException('done invalide');
  }

  final priorite = priorityCode is String
      ? prioriteDepuisCode(priorityCode)
      : null;
  if (priorite == null) {
    throw FormatException('priority invalide');
  }

  String? note;

  if (noteBrute == null) {
    note = null;
  } else if (noteBrute is String) {
    note = noteBrute.trim().isEmpty ? null : noteBrute;
  } else {
    throw FormatException('note invalide');
  }

  final d = parseEcheance(due);

  Tache newTache = Tache(
    id: id,
    title: title,
    priority: priorite,
    due: d,
    note: note,
    done: done,
  );

  return newTache;
}

String libelleEcheance(Echeance echeance) {
  switch (echeance.type) {
    case TypeEcheance.none:
      return 'sans échéance';

    case TypeEcheance.date:
      final d = echeance.date!;
      return 'pour le ${d.day}/${d.month}';

    case TypeEcheance.weekly:
      const noms = [
        'lundi',
        'mardi',
        'mercredi',
        'jeudi',
        'vendredi',
        'samedi',
        'dimanche',
      ];
      return 'chaque ${noms[echeance.weekDay! - 1]}';
  }
}

bool estEnRetard(Tache tache, {required DateTime aujourdhui}) {
  if (tache.done) return false;
  if (tache.due.type != TypeEcheance.date) return false;

  DateTime d = tache.due.date!;
  DateTime dateDue = DateTime(d.year, d.month, d.day);
  DateTime dateToday = DateTime(
    aujourdhui.year,
    aujourdhui.month,
    aujourdhui.day,
  );

  return dateDue.isBefore(dateToday);
}

({int faites, int total}) bilan(Iterable<Tache> taches) {
  int nbFaites = 0;
  int nbTotal = 0;

  if (taches.isEmpty) return (faites: 0, total: 0);

  for (Tache t in taches) {
    if (t.done) {
      nbFaites++;
      nbTotal++;
    } else {
      nbTotal++;
    }
  }

  return (faites: nbFaites, total: nbTotal);
}

List<Tache> aFaire(Iterable<Tache> taches, {Priority auMoins = Priority.low}) {
  List<Tache> newList = [];
  for (Tache t in taches) {
    if (!t.done) {
      if (t.priority.index >= auMoins.index) {
        newList.add(t);
      }
    }
  }
  newList.sort((a, b) {
    // Comparer les priorités (décroissant : haute avant basse)
    final parPriorite = b.priority.index.compareTo(a.priority.index);
    if (parPriorite != 0) {
      return parPriorite;
    }

    // Priorités égales : comparer les titres (croissant : A avant B)
    return a.title.compareTo(b.title);
  });

  return newList;
}

Echeance parseEcheance(Object? echeance) {
  if (echeance == null) {
    return const Echeance.none();
  }
  if (echeance is! String) {
    throw FormatException('"due" doit être une chaîne AAAA-MM-JJ ou null');
  }
  final date = DateTime.tryParse(echeance);
  if (date == null) {
    throw FormatException('"due" invalide : $echeance');
  }

  return Echeance.date(DateTime(date.year, date.month, date.day));
}
