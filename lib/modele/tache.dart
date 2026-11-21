
import 'dart:io';

import 'package:mes_taches/modele/due.dart';

enum Priority {
  low,
  normal,
  high
}

class Tache {
  final String id;
  final String title;
  final Priority priority;
  final Due due;
  final String? note;
  final bool done;

  const Tache({
    required this.id,
    required this.title,
    this.priority = Priority.normal,
    this.due = const Due.none(),
    this.note,
    this.done = false,
  });


 // renvoie le code de la priorité 
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

  Due parseDue(Object? due) {
    if (due == null) {
      return const Due.none();
    }
    if (due is! String) {
      throw FormatException('"due" doit être une chaîne AAAA-MM-JJ ou null');
    }
    final date = DateTime.tryParse(due); 
    if (date == null) {
      throw FormatException('"due" invalide : $due');
    }
   
      return Due.date(DateTime(date.year, date.month, date.day));
  }


Tache tacheDepuisJson(Map<String, Object?> json){
   final id = json['id'];
   final title = json['title'];
   final priorityCode= json['priority'];
   final note = json['note']?? '';
   final due = json['due'];
   final done = json['done'];
   
    
  if (id is! String || id.isEmpty) {
    throw FormatException('id invalide');
  }
    if (title is! String || title.isEmpty) {
    throw FormatException('title invalide');
  }
  if (done is! bool) {
    throw FormatException('done invalide');
  }

  final priorite = priorityCode is String ? prioriteDepuisCode(priorityCode) : null;
  if (priorite == null) {
    throw FormatException('priority invalide');
  }
  
  if(note is! String){
    throw FormatException('Note invalide');
  }


  final d = parseDue(due);

  Tache newTache = Tache(
    id: id,
    title: title,
    priority: priority,
    due: d,
    note: note,
    done: done    
    );

    return newTache;
}


}