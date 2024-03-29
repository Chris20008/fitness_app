import 'package:flutter/cupertino.dart';

import '../util/objectbox/ob_exercise.dart';

class Exercise{

  String name;
  List<SingleSet> sets;
  int restInSeconds;
  int? seatLevel;

  String? originalName;
  String? linkName;


  Exercise({
    this.name = "",
    this.sets = const [],
    this.restInSeconds = 0,
    this.seatLevel,
    this.originalName,
    this.linkName
  }){
    if (sets.isEmpty){
      sets = [];
      addSet();
    }
  }

  /// Don't clone the original name
  Exercise.clone(Exercise ex): this(
      name: ex.name,
      sets: List.from(ex.sets.map((set) => SingleSet(weight: set.weight, amount: set.amount))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
      linkName: ex.linkName
  );

  ObExercise toObExercise(){
    List<int> weights = [];
    List<int> amounts = [];
    sets = sets.where((set) => set.weight != null && set.amount != null).toList();
    for (SingleSet set in sets){
      weights.add(set.weight!);
      amounts.add(set.amount!);
    }
    return ObExercise(
        name: name,
        weights: weights,
        amounts: amounts,
        restInSeconds: restInSeconds,
        seatLevel: seatLevel,
        linkName: linkName
    );
  }

  List<Key> generateKeyForEachSet(){
    return sets.map((e) => UniqueKey()).toList();
  }

  void addSet({int? weight, int? amount}){
    sets.add(SingleSet(weight: weight, amount: amount));
  }

  void resetSets(){
    sets = sets.map((e) => SingleSet(weight:null, amount:null)).toList();
  }

  void removeEmptySets(){
    sets = sets.where((e) => e.weight != null && e.amount != null && e.weight! >= 0 && e.amount! > 0).toList();
  }

}

class SingleSet{
  int? weight;
  int? amount;

  SingleSet({
    this.weight,
    this.amount
  });
}