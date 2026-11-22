import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/components/my_card.dart';
import 'package:mes_taches/modele/echeance.dart';
import 'package:mes_taches/modele/tache.dart';
import 'package:mes_taches/modele/taches.dart';
import 'package:mes_taches/donnees/exemples.dart';
import 'package:mes_taches/pages/detail_tache.dart';

class PageTaches extends StatefulWidget {
  const PageTaches({super.key});

  @override
  State<PageTaches> createState() => _PageTachesState();
}

enum Filtre { toutes, aFaire, faites }

class _PageTachesState extends State<PageTaches> {
  late final List<Tache> _taches;

  @override
  void initState() {
    super.initState();
    final dynamique = jsonDecode(tachesExempleJson);
    if (dynamique is! List) {
      throw FormatException('tachesExempleJson doit être un tableau JSON');
    }
    _taches = dynamique
        .map((e) => tacheDepuisJson(e as Map<String, Object?>))
        .toList();
  }

  int get _nbAFaire => _taches.where((t) => !t.done).length;

  void _basculer(Tache tache) {
    setState(() {
      final index = _taches.indexWhere((t) => t.id == tache.id);
      if (index != -1) {
        _taches[index] = _taches[index].copyWith(faite: !_taches[index].done);
      }
    });
  }

  Future<void> _ouvrirModal() async {
    final titreController = TextEditingController();
    final noteController = TextEditingController();
    Priority priorite = Priority.normal;
    DateTime? echeance;

    String? erreurTitre;
    String? erreurNote;

    final nouvelleTache = await showDialog<Tache>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre + message d'erreur
                    TextField(
                      controller: titreController,
                      decoration: InputDecoration(
                        labelText: 'Titre',
                        errorText: erreurTitre,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Priorité
                    DropdownButton<Priority>(
                      value: priorite,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: Priority.low,
                          child: Text('Basse'),
                        ),
                        DropdownMenuItem(
                          value: Priority.normal,
                          child: Text('Normale'),
                        ),
                        DropdownMenuItem(
                          value: Priority.high,
                          child: Text('Haute'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => priorite = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Échéance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            echeance == null
                                ? 'Aucune échéance'
                                : '${echeance!.day}/${echeance!.month}/${echeance!.year}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final choisie = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (choisie != null) {
                              setModalState(() => echeance = choisie);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Note + message d'erreur
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Note (facultatif)',
                        errorText: erreurNote,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    final titre = titreController.text.trim();
                    final note = noteController.text.trim();

                    // Validation
                    String? eTitre;
                    String? eNote;

                    if (titre.isEmpty) {
                      eTitre = 'Le titre est obligatoire';
                    } else if (titre.length > 60) {
                      eTitre = '60 caractères maximum';
                    }

                    if (note.length > 200) {
                      eNote = '200 caractères maximum';
                    }

                    if (eTitre != null || eNote != null) {
                      setModalState(() {
                        erreurTitre = eTitre;
                        erreurNote = eNote;
                      });
                      return; // on ne ferme pas
                    }

                    // Tout est valide : on construit la tâche
                    final tache = Tache(
                      id: 't-${DateTime.now().microsecondsSinceEpoch}',
                      title: titre,
                      priority: priorite,
                      due: echeance == null
                          ? const Echeance.none()
                          : Echeance.date(echeance!),
                      note: note.isEmpty ? null : note,
                    );

                    Navigator.pop(context, tache);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (nouvelleTache == null) return;
    if (!mounted) return;

    setState(() {
      _taches.add(nouvelleTache);
    });
  }

  Future<void> _ouvrirDetail(Tache tache) async {
    final modifiee = await Navigator.push<Tache>(
      context,
      MaterialPageRoute(builder: (_) => DetailTache(tache: tache)),
    );

    if (modifiee == null) return; // simple retour, pas d'action
    if (!mounted) return;

    setState(() {
      final index = _taches.indexWhere((t) => t.id == modifiee.id);
      if (index != -1) {
        _taches[index] = modifiee; // remplace par la version modifiée
      }
    });
  }

  final itemsFiltre = ['Toutes', 'à Faire', 'Faites'];
  String? selectedFiltre;

  @override
  Widget build(BuildContext context) {
    final visibles = _taches.where((t) {
      if (selectedFiltre == 'à Faire') return !t.done;
      if (selectedFiltre == 'Faites') return t.done;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        backgroundColor: Color.fromARGB(255, 255, 248, 150),
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$_nbAFaire à faire',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: selectedFiltre ?? 'Toutes',
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: itemsFiltre.map(buildMenuItem).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedFiltre = value);
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: (visibles.isEmpty)
                ? Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Liste ',
                        style: const TextStyle(fontSize: 20),
                        children: [
                          TextSpan(
                            text: '< $selectedFiltre >',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // ou la couleur que tu veux
                            ),
                          ),
                          const TextSpan(text: ' est vide.'),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: visibles.length,
                    itemBuilder: (context, index) {
                      final tache = visibles[index];
                      return MyCard(
                        tache: tache,
                        ouvrirDetail: () => _ouvrirDetail(tache),
                        onToggle: () => _basculer(tache),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirModal,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem<String>(
        value: item,
        child: Row(
          children: [
            //Icon(icone, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(item),
          ],
        ),
      );
}
