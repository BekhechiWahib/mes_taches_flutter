import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/modele/tache.dart';
import 'package:mes_taches/modele/taches.dart'; // pour libelleEcheance, estEnRetard

class MyCard extends StatelessWidget {
  // 1. Les champs
  final Tache tache;
  final Function ouvrirDetail;
  final VoidCallback onToggle;

  // 2. Le constructeur
  const MyCard({
    super.key,
    required this.tache,
    required this.ouvrirDetail,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final enRetard = estEnRetard(tache, aujourdhui: DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => ouvrirDetail(),
        leading: Checkbox(value: tache.done, onChanged: (_) => onToggle()),
        title: Text(
          tache.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: tache.done ? TextDecoration.lineThrough : null,
            color: tache.done ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          libelleEcheance(tache.due),
          style: TextStyle(
            color: enRetard ? Colors.red : null,
            fontWeight: enRetard ? FontWeight.bold : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [_PastillePriority(priority: tache.priority)],
        ),
      ),
    );
  }
}

class _PastillePriority extends StatelessWidget {
  final Priority priority;

  const _PastillePriority({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (couleur, libelle) = switch (priority) {
      Priority.low => (Colors.green, 'Basse'),
      Priority.normal => (Colors.orange, 'Normale'),
      Priority.high => (Colors.red, 'Haute'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          color: couleur,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
