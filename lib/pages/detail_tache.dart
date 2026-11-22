import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/modele/tache.dart';
import 'package:mes_taches/modele/taches.dart';

class DetailTache extends StatelessWidget {
  final Tache tache;

  const DetailTache({super.key, required this.tache});

  @override
  Widget build(BuildContext context) {
    final enRetard = estEnRetard(tache, aujourdhui: DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        backgroundColor: const Color.fromARGB(255, 255, 248, 150),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tache.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Priorité
          _Ligne(
            label: 'Priorité',
            valeur: switch (tache.priority) {
              Priority.low => 'Basse',
              Priority.normal => 'Normale',
              Priority.high => 'Haute',
            },
          ),

          _Ligne(
            label: 'Échéance',
            valeur: libelleEcheance(tache.due),
            enRouge: enRetard,
          ),

          // Note
          _Ligne(
            label: 'Note',
            valeur: (tache.note == null || tache.note!.isEmpty)
                ? 'pas de note'
                : tache.note!,
          ),

          // État
          _Ligne(label: 'État', valeur: tache.done ? 'faite' : 'à faire'),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context, tache.copyWith(faite: !tache.done));
            },
            icon: Icon(tache.done ? Icons.undo : Icons.check),
            label: Text(tache.done ? 'Marquer à faire' : 'Marquer comme faite'),
          ),
        ],
      ),
    );
  }
}

/// Petit widget réutilisable pour afficher "Label : valeur"
class _Ligne extends StatelessWidget {
  final String label;
  final String valeur;
  final bool enRouge;

  const _Ligne({
    required this.label,
    required this.valeur,
    this.enRouge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: TextStyle(
                color: enRouge ? Colors.red : null,
                fontWeight: enRouge ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
