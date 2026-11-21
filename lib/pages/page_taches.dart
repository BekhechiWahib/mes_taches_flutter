
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Écran provisoire.
class PageTaches extends StatefulWidget {
  const PageTaches();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Le projet se lance.\n'
            'Remplacez cet écran par votre ddddddddd liste de tâches (partie B).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
