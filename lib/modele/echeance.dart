enum TypeEcheance { none, date, weekly }

class Echeance {
  final TypeEcheance type;
  final DateTime? date; // utilisé seulement si type == date
  final int? weekDay; // utilisé seulement si type == hebdomadaire (1 = lundi, 7 = dimanche)

  // Constructeur privé pour forcer l'utilisation des fabriques
  const Echeance({required this.type, this.date, this.weekDay});

  // Pas d'échéance
  const Echeance.none() : type = TypeEcheance.none, date = null, weekDay = null;

  // Échéance à une date précise
  Echeance.date(DateTime date)
    : type = TypeEcheance.date,
      date = DateTime(date.year, date.month, date.day),
      weekDay = null;

  // Échéance hebdomadaire
  Echeance.weekly(int day)
    : type = TypeEcheance.weekly,
      date = null,
      weekDay = day {
    if (day < 1 || day > 7) {
      throw ArgumentError('Le jour doit être entre 1 et 7');
    }
  }
}
