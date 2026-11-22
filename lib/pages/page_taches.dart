import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mes_taches/components/my_card.dart';
import 'package:mes_taches/modele/tache.dart';
import 'package:mes_taches/modele/taches.dart';
import 'package:mes_taches/donnees/exemples.dart';

class PageTaches extends StatefulWidget {
  const PageTaches({super.key});

  @override
  State<PageTaches> createState() => _PageTachesState();
}

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
   String _nouveauTitre = '';

  void _basculer(Tache tache) {
    setState(() {
      final index = _taches.indexWhere((t) => t.id == tache.id);
      if (index != -1) {
        _taches[index] =
            _taches[index].copyWith(faite: !_taches[index].done);
      }
    });
  }

  void _ajouterExemple() {
    setState(() {
      _taches.add(
        Tache(
          id: 'exemple-${DateTime.now().microsecondsSinceEpoch}',
          title: 'Nouvelle tâche d\'exemple',
          priority: Priority.normal,
        ),
      );
    });
  }

  void _ouvrirModal() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: TextField(
          onChanged: (v) => _nouveauTitre = v,
          decoration: const InputDecoration(labelText: 'Titre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _taches.add(Tache(
                  id: 't-${DateTime.now().microsecondsSinceEpoch}',
                  title: _nouveauTitre,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      );
    },
  );
}



   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        backgroundColor: Color.fromARGB(255, 255, 248, 150),        
        ),
      body: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: _taches.length,
              itemBuilder: (context, index) {
                final tache = _taches[index];
                return MyCard(
                  tache: tache,
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
}


