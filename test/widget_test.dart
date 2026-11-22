import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/main.dart';

void main() {
  // ---------------------------------------------------------------
  // B2 — Cocher une tâche met à jour le compteur
  // ---------------------------------------------------------------
  testWidgets('cocher une tâche met à jour le compteur', (tester) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.pumpAndSettle();

    // 6 tâches, t1 faite → 5 à faire
    expect(find.text('5 à faire'), findsOneWidget);

    // t1 est le premier Checkbox (déjà fait). On clique le deuxième (t2, non fait).
    final cases = find.byType(Checkbox);
    await tester.tap(cases.at(1));
    await tester.pumpAndSettle();

    // t2 devient faite → 4 à faire
    expect(find.text('4 à faire'), findsOneWidget);
  });

  // ---------------------------------------------------------------
  // C1 — Le filtre « à Faire » masque les tâches faites
  // ---------------------------------------------------------------
  testWidgets('le filtre « à Faire » masque les tâches faites', (tester) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.pumpAndSettle();

    // 6 tâches affichées au départ
    expect(find.byType(Checkbox), findsNWidgets(6));

    // Ouvre le dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Choisit 'à Faire' (avec F majuscule, comme dans itemsFiltre)
    await tester.tap(find.text('à Faire').last);
    await tester.pumpAndSettle();

    // Seulement les 5 non faites
    expect(find.byType(Checkbox), findsNWidgets(5));
  });

  // ---------------------------------------------------------------
  // D1 + D2 — Ouvrir le détail et agir avec un filtre actif
  // ---------------------------------------------------------------
  testWidgets('ouvrir le détail puis marquer faite met à jour la liste', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.pumpAndSettle();

    // Active le filtre 'à Faire'
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('à Faire').last);
    await tester.pumpAndSettle();

    // Ouvre la première tâche non faite (t2)
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // On est sur le détail
    expect(find.text('Détail'), findsOneWidget);

    // Marque faite
    await tester.tap(find.text('Marquer comme faite'));
    await tester.pumpAndSettle();

    // Retour à la liste : compteur passé de 5 à 4
    expect(find.text('4 à faire'), findsOneWidget);
  });

  // ---------------------------------------------------------------
  // E2 — Formulaire vide refusé, modale reste ouverte
  // ---------------------------------------------------------------
  testWidgets('un formulaire vide est refusé et reste ouvert', (tester) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Le titre est obligatoire'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsOneWidget);
  });

  // ---------------------------------------------------------------
  // E1 — Création d'une tâche valide, visible dans la liste
  // ---------------------------------------------------------------
  testWidgets('une tâche valide apparaît dans la liste', (tester) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Acheter du pain');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // Fait défiler la liste jusqu'à trouver le texte
    await tester.scrollUntilVisible(
      find.text('Acheter du pain'),
      200, // pixels par cran
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Acheter du pain'), findsOneWidget);
  });
}
