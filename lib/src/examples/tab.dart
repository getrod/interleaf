import 'package:flutter/material.dart';

class TabBarDemo extends StatelessWidget {
  
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
                Tab(child: Text("CHATS", style: TextStyle(fontWeight: FontWeight.bold)),),
                Tab(child: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold)),),
                Tab(child: Text("CALLS", style: TextStyle(fontWeight: FontWeight.bold)),),
              ],
            ),
            title: Text("Tab Demo"),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(color: Colors.blue,),
              Container(color: Colors.red,),
              Container(color: Colors.yellow,),
            ],
          ),
        ),
      ),
    );
  }
}
