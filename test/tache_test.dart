// test/modele/taches_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/modele/echeance.dart';
import 'package:mes_taches/modele/tache.dart';
import 'package:mes_taches/modele/taches.dart';

void main() {
  // ---------------------------------------------------------------
  // A1 — prioriteDepuisCode
  // ---------------------------------------------------------------
  group('prioriteDepuisCode', () {
    test('renvoie basse pour low', () {
      expect(prioriteDepuisCode('low'), Priority.low);
    });

    test('renvoie normale pour normal', () {
      expect(prioriteDepuisCode('normal'), Priority.normal);
    });

    test('renvoie haute pour high', () {
      expect(prioriteDepuisCode('high'), Priority.high);
    });

    test('renvoie null pour un code inconnu', () {
      expect(prioriteDepuisCode('High'), isNull);
      expect(prioriteDepuisCode('urgent'), isNull);
      expect(prioriteDepuisCode(''), isNull);
    });
  });

  // ---------------------------------------------------------------
  // A1 — tacheDepuisJson
  // ---------------------------------------------------------------
  group('tacheDepuisJson', () {
    test('lit un document valide sans échéance ni note', () {
      final t = tacheDepuisJson({
        'id': 't1',
        'title': 'Installer Flutter',
        'priority': 'high',
        'done': true,
      });

      expect(t.id, 't1');
      expect(t.title, 'Installer Flutter');
      expect(t.priority, Priority.high);
      expect(t.done, isTrue);
      expect(t.note, isNull);
      expect(t.due.type, TypeEcheance.none);
    });

    test('lit un document valide avec échéance et note', () {
      final t = tacheDepuisJson({
        'id': 't2',
        'title': 'Payer le loyer',
        'priority': 'low',
        'done': false,
        'due': '2026-12-01',
        'note': 'virement',
      });

      expect(t.id, 't2');
      expect(t.note, 'virement');
      expect(t.due.type, TypeEcheance.date);
      expect(t.due.date, DateTime(2026, 12, 1));
    });

    test('lève FormatException si id absent', () {
      expect(
        () => tacheDepuisJson({'title': 'x', 'priority': 'low', 'done': false}),
        throwsFormatException,
      );
    });

    test('lève FormatException si id vide', () {
      expect(
        () => tacheDepuisJson({'id': '', 'title': 'x', 'priority': 'low', 'done': false}),
        throwsFormatException,
      );
    });

    test('lève FormatException si title vide', () {
      expect(
        () => tacheDepuisJson({'id': 'a', 'title': '  ', 'priority': 'low', 'done': false}),
        throwsFormatException,
      );
    });

    test('lève FormatException si priority inconnue', () {
      expect(
        () => tacheDepuisJson({'id': 'a', 'title': 'x', 'priority': 'urgent', 'done': false}),
        throwsFormatException,
      );
    });

    test('lève FormatException si done n\'est pas un booléen', () {
      expect(
        () => tacheDepuisJson({'id': 'a', 'title': 'x', 'priority': 'low', 'done': 'non'}),
        throwsFormatException,
      );
    });

    test('lève FormatException si due n\'est pas une date lisible', () {
      expect(
        () => tacheDepuisJson({
          'id': 'a',
          'title': 'x',
          'priority': 'low',
          'done': false,
          'due': 'demain',
        }),
        throwsFormatException,
      );
    });
  });

  // ---------------------------------------------------------------
  // A2 — libelleEcheance
  // ---------------------------------------------------------------
  group('libelleEcheance', () {
    test('sans échéance', () {
      expect(libelleEcheance(const Echeance.none()), 'sans échéance');
    });

    test('date', () {
      expect(libelleEcheance(Echeance.date(DateTime(2026, 12, 1))), 'pour le 1/12');
    });

    test('hebdomadaire', () {
      expect(
        libelleEcheance(Echeance.weekly(6)),
        'chaque samedi',
      );
    });
  });

  // ---------------------------------------------------------------
  // A2 — estEnRetard
  // ---------------------------------------------------------------
  group('estEnRetard', () {
    final aujourdhui = DateTime(2026, 11, 21, 15); // samedi 21 nov 2026, 15h

    test('veille non faite → en retard', () {
      final t = Tache(
        id: 'a',
        title: 'x',
        due: Echeance.date(DateTime(2026, 11, 20)),
        done: false,
      );
      expect(estEnRetard(t, aujourdhui: aujourdhui), isTrue);
    });

    test('veille faite → pas en retard', () {
      final t = Tache(
        id: 'a',
        title: 'x',
        due: Echeance.date(DateTime(2026, 11, 20)),
        done: true,
      );
      expect(estEnRetard(t, aujourdhui: aujourdhui), isFalse);
    });

    test('même jour, heure différente → pas en retard', () {
      final t = Tache(
        id: 'a',
        title: 'x',
        due: Echeance.date(DateTime(2026, 11, 21, 8)),
        done: false,
      );
      expect(estEnRetard(t, aujourdhui: aujourdhui), isFalse);
    });

    test('sans échéance → pas en retard', () {
      final t = Tache(id: 'a', title: 'x', done: false);
      expect(estEnRetard(t, aujourdhui: aujourdhui), isFalse);
    });

    test('hebdomadaire → pas en retard', () {
      final t = Tache(
        id: 'a',
        title: 'x',
        due: Echeance.weekly(1),
        done: false,
      );
      expect(estEnRetard(t, aujourdhui: aujourdhui), isFalse);
    });
  });

  // ---------------------------------------------------------------
  // A3 — bilan
  // ---------------------------------------------------------------
  group('bilan', () {
    test('collection vide', () {
      final b = bilan(const <Tache>[]);
      expect(b.faites, 0);
      expect(b.total, 0);
    });

    test('collection non vide', () {
      final taches = [
        Tache(id: 'a', title: 'x', done: true),
        Tache(id: 'b', title: 'y', done: false),
        Tache(id: 'c', title: 'z', done: true),
      ];
      final b = bilan(taches);
      expect(b.faites, 2);
      expect(b.total, 3);
    });
  });

  // ---------------------------------------------------------------
  // A3 — aFaire
  // ---------------------------------------------------------------
  group('aFaire', () {
    final taches = [
      Tache(id: '1', title: 'Courses', priority: Priority.low),
      Tache(id: '2', title: 'Dentiste', priority: Priority.normal),
      Tache(id: '3', title: 'Passeport', priority: Priority.high),
      Tache(id: '4', title: 'Installer', priority: Priority.high, done: true),
      Tache(id: '5', title: 'Banque', priority: Priority.normal),
    ];

    test('filtre les tâches faites et trie par priorité puis titre', () {
      final resultat = aFaire(taches);
      expect(resultat.map((t) => t.title), ['Passeport', 'Banque', 'Dentiste', 'Courses']);
    });

    test('respecte auMoins: normale', () {
      final resultat = aFaire(taches, auMoins: Priority.normal);
      expect(resultat.map((t) => t.title), ['Passeport', 'Banque', 'Dentiste']);
    });

    test('ne modifie pas la collection reçue', () {
      final copie = List<Tache>.from(taches);
      aFaire(taches);
      expect(taches, copie);
    });

    test('priorités égales → ordre par titre', () {
      final resultat = aFaire(taches, auMoins: Priority.normal);
      // Banque avant Dentiste, car même priorité normale
      expect(resultat[1].title, 'Banque');
      expect(resultat[2].title, 'Dentiste');
    });
  });

  // ---------------------------------------------------------------
  // Immuabilité (A1)
  // ---------------------------------------------------------------
  group('immuabilité', () {
    test('copyWith change un champ sans modifier l\'originale', () {
      final t = Tache(id: 'a', title: 'x', priority: Priority.low);
      final t2 = t.copyWith(faite: true);

      expect(t.done, isFalse); // originale intacte
      expect(t2.done, isTrue); // nouvelle tâche modifiée
      expect(t2.id, t.id); // même id
    });

    test('copyWith peut effacer la note', () {
      final t = Tache(id: 'a', title: 'x', note: 'une note');
      final t2 = t.copyWith(effacerNote: true);
      expect(t.note, 'une note');
      expect(t2.note, isNull);
    });
  });
}