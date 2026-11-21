enum TypeDue {
  none,
  date,
  weekly,
}

class Due {
  final TypeDue type;
  final DateTime? date; // utilisé seulement si type == date
  final int? weekDay; // utilisé seulement si type == hebdomadaire (1 = lundi, 7 = dimanche)

  // Constructeur privé pour forcer l'utilisation des fabriques
  const Due({required this.type, this.date, this.weekDay});

  // Pas d'échéance
  const Due.none()
      : type = TypeDue.none,
        date = null,
        weekDay = null;

  // Échéance à une date précise
  Due.date(DateTime date)
      : type = TypeDue.date,
        date = DateTime(date.year, date.month, date.day),
        weekDay = null;

  // Échéance hebdomadaire
  Due.weekly(int day)
      : type = TypeDue.weekly,
        date = null,
        weekDay = day {
    if (day < 1 || day > 7) {
      throw ArgumentError('Le jour doit être entre 1 et 7');
    }
  }
  
}