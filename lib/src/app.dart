import 'package:flutter/material.dart';
import 'pages/decks/deck_list_page.dart';
import 'pages/study/study_page.dart';
import 'pages/stats/stats_page.dart';

class App extends StatelessWidget {

  Widget build (context) {
    return MaterialApp (
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange[900],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(child: Text("DECKS", style: TextStyle(fontWeight: FontWeight.bold)),),
                Tab(child: Text("STUDY", style: TextStyle(fontWeight: FontWeight.bold)),),
                Tab(child: Text("STATS", style: TextStyle(fontWeight: FontWeight.bold)),),
              ],
            ),
            title: Text("Interleaf"),
          ),
          body: TabBarView(
            children: <Widget>[
              DeckListPage(),
              StudyPage(),
              StatsPage(),
            ],
          ),
        ),
      ),
    );
  }

}