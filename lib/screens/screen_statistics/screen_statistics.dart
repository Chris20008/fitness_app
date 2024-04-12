import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/screen_statistics/overwiew_per_interval.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';
import 'interval_selector.dart';

class ScreenStatistics extends StatefulWidget {
  const ScreenStatistics({super.key});

  @override
  State<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends State<ScreenStatistics> {
  late CnScreenStatistics cnScreenStatistics;

  @override
  Widget build(BuildContext context) {
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);

    return ListView(

      children: const [
        SizedBox(height: 20),
        IntervalSelector(),
        SizedBox(height: 20),
        OverviewPerInterval()
        // SizedBox(height: 20,),
        // Averages(),
        // SizedBox(height: 20,),
        // GeneralOverviewBarChart()
      ],
    );
  }
}

class CnScreenStatistics extends ChangeNotifier {
  bool isInitialized = false;
  // late List<Workout> allWorkouts;
  Map<int, dynamic> workoutsSorted = {};
  DateTime minDate = DateTime.now();
  // DateTime minDate = DateTime(2024, 4, 5);
  DateTime maxDate = DateTime.now().add(const Duration(days: 32));
  // DateTime maxDate = DateTime(2025, 5, 26);
  Map<String, Map<String, DateTime>> intervalSelectorMap = {};
  late String currentlySelectedIntervalAsText = DateFormat('MMMM y').format(DateTime.now());
  // late DateTime currentlySelectedIntervalAsDate = DateTime.now();
  TimeInterval selectedIntervalSize = TimeInterval.monthly;


  void init() async{
    // final tempObWorkouts = await objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date).build().findAsync();// .getAllAsync();
    // allWorkouts = List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
    isInitialized = true;
    setMinDate();
    refreshIntervalSelectorMap();
    print("INTERVALL SELECTOR MAP:");
    for(final i in intervalSelectorMap.entries){
      print(i);
    }
  }

  void refreshIntervalSelectorMap(){
    intervalSelectorMap.clear();
    bool isSmaller = true;
    late DateTime tempMinDate;
    switch (selectedIntervalSize){
      case TimeInterval.yearly:
        tempMinDate = DateTime(minDate.year, 1, 1, 0, 0, 0);
        break;
      case TimeInterval.quarterly:
        final subtractionFromMonth = (minDate.month-1)%3;
        tempMinDate = DateTime(minDate.year, minDate.month - subtractionFromMonth, 1, 0, 0, 0);
        break;
      default:
        tempMinDate = minDate.copyWith(day: 1, hour: 0, minute: 0, second: 0);
    }
    while (isSmaller){

      late String intervalKey;
      switch (selectedIntervalSize){
        case TimeInterval.yearly:
          intervalKey = DateFormat('y').format(tempMinDate);
          break;
        case TimeInterval.quarterly:
          intervalKey = DateFormat('QQQ y').format(tempMinDate);
          break;
        default:
          intervalKey = DateFormat('MMMM y').format(tempMinDate);
      }

      /// set temp max date
      late DateTime tempMaxDate;
      switch (selectedIntervalSize){

        /// yearly new temp max date
        case TimeInterval.yearly:
          tempMaxDate = tempMinDate.add(
              Duration(days: isLeapYear(tempMinDate.year)? 366: 365)
          ).copyWith(
              hour: 0,
              minute: 0,
              second: 0
          );
          break;

        /// quarterly new temp max date
        case TimeInterval.quarterly:
          tempMaxDate = tempMinDate.add(
              Duration(days: getMaxDaysOfMonth(tempMinDate))
          );
          for (num _ in range(1, 3)){
            tempMaxDate = tempMaxDate.add(Duration(days: getMaxDaysOfMonth(tempMaxDate)));
          }
          tempMaxDate = tempMaxDate.copyWith(hour: 0, minute: 0, second: 0);
          intervalKey = DateFormat('QQQ y').format(tempMinDate);
          break;

        /// monthly new temp max date
        default:
          tempMaxDate = tempMinDate.add(
              Duration(days: getMaxDaysOfMonth(tempMinDate))
          ).copyWith(
              hour: 0,
              minute: 0,
              second: 0
          );
          /// Due to German TimeCorrection in March and October it can happen, that the month is still
          /// the same, due to adding one day always adds 24 hours beeing to less in october where one day is 25 hours long
          if(tempMaxDate.month == tempMinDate.month){
            tempMaxDate = tempMaxDate.add(const Duration(days: 1));
          }
      }
      intervalSelectorMap[intervalKey] = {
        "minDate": tempMinDate,
        "maxDate": tempMaxDate
      };

      if(DateTime.now().isAfter(tempMinDate) && DateTime.now().isBefore(tempMaxDate)){
        currentlySelectedIntervalAsText = intervalKey;
      }
      if(tempMaxDate.isAfter(maxDate)){
        isSmaller = false;
      }
      else{
        tempMinDate = tempMaxDate.copyWith(
            hour: 0,
            minute: 0,
            second: 0
        );
      }

    }
  }
  
  Future<List<Workout>> getWorkoutsInInterval()async{
    final tempObWorkouts = await objectbox.workoutBox.query(
        ObWorkout_.isTemplate.equals(false)
            .and(ObWorkout_.date.betweenDate(intervalSelectorMap[currentlySelectedIntervalAsText]!["minDate"]!, intervalSelectorMap[currentlySelectedIntervalAsText]!["maxDate"]!))
        ).order(ObWorkout_.date).build().findAsync();
    return List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
  }

  Future<Map<String, Map>> getWorkoutsInIntervalSummarized() async{
    print("IN FUNCTION: getWorkoutsInIntervalSummarized");
    Map<String, Map> summarized = {};
    final workouts = await getWorkoutsInInterval();
    print("RECEIVED WORKOUTS. $workouts");
    for(Workout w in workouts){
      print(w.name);
      if(summarized.containsKey(w.name)){
        summarized[w.name]!["counter"] = summarized[w.name]!["counter"] + 1;
      } else{
        summarized[w.name] = {"counter": 1};
      }
    }
    final sortedSummarized = Map.fromEntries(
        summarized.entries.toList()..sort((e1, e2) => e2.value["counter"].compareTo(e1.value["counter"]))
    );
    return sortedSummarized;
  }

  // void getWeeksFromMonth(int year, int month) async{
  //   final firstDayOfMonth = DateTime(year=year, month, 1);
  //   final lastDayOfMonth = DateTime(year=year, month, getMaxDaysOfMonth(firstDayOfMonth));
  //
  //   final DateTime firstMonday = getMondayOfWeekFromDay(firstDayOfMonth);
  //   final DateTime lastSunday = getSundayOfWeekFromDay(lastDayOfMonth);
  //
  //   final tempObWorkouts = await objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false).and(ObWorkout_.date.betweenDate(firstMonday, lastSunday))).order(ObWorkout_.date).build().findAsync();
  //   List<Workout> tempWorkouts = List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
  //
  // }

  // DateTime getMondayOfWeekFromDay(DateTime date){
  //   final int weekday = weekdayMapping[DateFormat('E').format(date)]!;
  //   return date.subtract(Duration(days: weekday -1));
  // }
  //
  // DateTime getSundayOfWeekFromDay(DateTime date){
  //   return getMondayOfWeekFromDay(date).add(const Duration(days: 6));
  // }

  // void calcFoundation(){
  //   bool addNewWeek = true;
  //
  //   for(num year in range(minDate.year, maxDate.year + 1)){
  //     workoutsSorted[year.toInt()] = {};
  //   }
  //   DateTime currentMonday = getMondayOfWeekFromDay(minDate);
  //   while (addNewWeek){
  //     final int dayOfMonthMonday = int.parse(DateFormat('d').format(currentMonday));
  //     final int monthMonday = int.parse(DateFormat('M').format(currentMonday));
  //     final sunday = currentMonday.add(const Duration(days: 6));
  //     final int dayOfMonthSunday = int.parse(DateFormat('d').format(sunday));
  //     final int monthSunday = int.parse(DateFormat('M').format(sunday));
  //     workoutsSorted[currentMonday.year][DateFormat('yMd').format(currentMonday)] = {
  //       "name": "$dayOfMonthMonday.$monthMonday - $dayOfMonthSunday.$monthSunday",
  //       "counter": 0
  //     };
  //     currentMonday = sunday.add(const Duration(days:1));
  //     if(maxDate.isBefore(sunday)){
  //       addNewWeek = false;
  //     }
  //   }
  // }

  void setMinDate()async{
    ObWorkout? firstWorkout = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date).build().findFirst();// .getAllAsync();
    if(firstWorkout != null){
      minDate = firstWorkout.date;
    }
  }

  // void sortWorkoutsInMap(){
  //   for(Workout w in allWorkouts){
  //     final year = w.date!.year;
  //     final int weekday = weekdayMapping[DateFormat('E').format(w.date!)]!;
  //     final weekKey = DateFormat('yMd').format(w.date!.subtract(Duration(days: weekday - 1)));
  //     workoutsSorted[year][weekKey]["counter"] = workoutsSorted[year][weekKey]["counter"] + 1;
  //   }
  // }

  final weekdayMapping = {
    "Mon": 1,
    "Tue": 2,
    "Wed": 3,
    "Thu": 4,
    "Fri": 5,
    "Sat": 6,
    "Sun": 7,
  };

  int getMaxDaysOfMonth(DateTime date){
    switch (date.month){
      case 4 || 6 || 9 || 11:
        return 30;
      case 2:
        return isLeapYear(date.year)? 29: 28;
      default:
        return 31;
    }
  }

  bool isLeapYear(int year){
    return (year%4==0 && (year%100!=0 || year%400==0));
  }

  void refresh(){
    notifyListeners();
  }
}