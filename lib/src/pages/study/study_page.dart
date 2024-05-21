import 'dart:async';
import 'package:flutter/material.dart';
import 'package:interleaf/src/platform/local_storage.dart';
import 'package:interleaf/src/models/deck.dart';
import 'session_page.dart';

class StudyPage extends StatefulWidget {
  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  List<bool> values;
  List<Deck> studyDecks = [];
  Deck deckToStudy;
  int numberOfCards = 0;

  @override
  void initState() {
    super.initState();
    values =  List<bool>.filled(LocalStorage.tempDecks.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: deckCheckList(),
    );
  }

  Widget deckCheckList() {
    return ListView.builder(
      itemCount: LocalStorage.tempDecks.length + 1,
      itemBuilder: (context, count) {
        if (count == 0) {
          return studyButton();
        } else {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: deckCheckListBox(count - 1),
          );
        }
      },
    );
  }

  Widget deckCheckListBox(int listIndex) {
    return Column(
      children: <Widget>[
        //Row: CheckBox & DeckName
        Row(
          children: <Widget>[
            Checkbox(
                activeColor: Colors.orange,
                value: values[listIndex],
                onChanged: (bool newValue) {
                  setState(() {
                    values[listIndex] = newValue;
                    if (newValue == true) {
                      studyDecks.add(LocalStorage.tempDecks[listIndex]);
                    } else {
                      studyDecks.remove(LocalStorage.tempDecks[listIndex]);
                    }
                  });
                },
            ),
            Text(LocalStorage.tempDecks[listIndex].deckName, 
              style: TextStyle(color: Colors.orange[900], fontSize: 16),
            ),
          ],
        ),
        //Divider
        Divider(),
      ]
    );
  }

  Widget studyButton() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: ButtonTheme(
        height: 60,
        child: RaisedButton(
          child: Text("STUDY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
          color: Colors.orange[900],
          onPressed: studyFunction(),
        ),
      )
    );
  }

  Function studyFunction() {
    if (studyDecks.length > 0) {
      return () async {
        if (studyDecks.length > 0) {
          //find the total amount of cards in these decks
          //and make that the max number for studyButtonPopup
          int maxNumberCards = 0;

          //print(studyDecks);

          for (int i = 0; i < studyDecks.length; i++) {
            maxNumberCards += studyDecks[i].cards.length;
          }

          int studyMethod = await studyMethodPopup();
          if (studyMethod != null) {
            int selectedNumberOfCards = await studyButtonPopup(1, maxNumberCards);
            if (selectedNumberOfCards != null) {
              //Create merged new deck 
              deckToStudy = Deck.mergeDecks(studyDecks);
              //shuffle cards
              deckToStudy.cards.shuffle();
              //with sorted cards
              if (studyMethod == 1) {
                Deck.sortCardsByPScore(deckToStudy);
              }
              //Study out of selected amount of cards
              deckToStudy.cards.removeRange(selectedNumberOfCards, deckToStudy.cards.length);
              //to send it to study session page
              //print(deckToStudy);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudySessionPage(deckToStudy)),
              );
            }
          }
        }
      };
    } else {
      null;
    }
  }

  Future<int> studyMethodPopup() {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Study Method'),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: 120,
              maxWidth: 150,
              minHeight: 50,
              minWidth: 50,
            ),
            child: GridView.count(
              primary: false,
              crossAxisCount: 2,
              children: <Widget>[
                ////Priority: 1
                Container(
                  margin: EdgeInsets.all(4),
                  child: ButtonTheme(
                    height: 10,
                    minWidth: 150,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.pop(context, 1);
                      },
                      child: Column(
                        children: <Widget>[
                          Spacer(flex: 5,),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Icon(Icons.low_priority, color: Colors.white,),
                          ),
                          Spacer(),
                          Text('PRIORITY', style: TextStyle(color: Colors.white),),
                          Spacer(flex: 5,),
                        ],
                      ),
                      color: Colors.orange,
                    ),
                  ),
                ),
                ////Shuffle: 2
                Container(
                  margin: EdgeInsets.all(4),
                  child: ButtonTheme(
                    height: 10,
                    minWidth: 150,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.pop(context, 2);
                      },
                      child: Column(
                        children: <Widget>[
                          Spacer(flex: 5,),
                          Icon(Icons.shuffle, color: Colors.white,),
                          Spacer(),
                          Text('SHUFFLE', style: TextStyle(color: Colors.white),),
                          Spacer(flex: 5,),
                        ],
                      ),
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: <Widget>[
          //       //Priority: 1
          //       //Shuffle: 2
          //       Container(
          //         color: Colors.amber, 
          //         margin: EdgeInsets.all(4),
          //         child: ButtonTheme(
          //           height: 10,
          //           minWidth: 150,
          //           child: FlatButton(
          //             onPressed: (){
                        
          //             },
          //             child: Icon(Icons.sentiment_dissatisfied, color: Colors.white,),
          //             color: Colors.red,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         color: Colors.amber, 
          //         margin: EdgeInsets.all(4),
          //         child: ButtonTheme(
          //           height: 10,
          //           minWidth: 150,
          //           child: FlatButton(
          //             onPressed: (){
                        
          //             },
          //             child: Icon(Icons.sentiment_neutral, color: Colors.white,),
          //             color: Colors.lime,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );    
  }

  Future<int> studyButtonPopup(int min, int max) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return NumberOfCardsDialog(min, max);
      },
    );
  } 
}

class NumberOfCardsDialog extends StatefulWidget {
  final int min;
  final int max;
  NumberOfCardsDialog(this.min, this.max);
  @override
  _NumberOfCardsDialogState createState() => _NumberOfCardsDialogState();
}

class _NumberOfCardsDialogState extends State<NumberOfCardsDialog> {
  int numberOfCards = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('How many cards?'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            numberSelector()
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          textColor: Colors.orange[900],
          child: Text('OK'),
          onPressed: () {
            if (numberOfCards > 0) {
              Navigator.pop(context, numberOfCards);
            }
          },
        ),
        FlatButton(
          textColor: Colors.orange[900],
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget numberSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Icon(Icons.arrow_left),
          onPressed: (){
            setState(() {
              if (widget.min < numberOfCards) {
                numberOfCards--;
              }
            });
          },
        ),
        Text('$numberOfCards'),
        FlatButton(
          child: Icon(Icons.arrow_right),
          onPressed: (){
            setState(() {
              if (widget.max > numberOfCards) {
                numberOfCards++;
              }
            });
          },
        ),
      ],
    );
  } 
}

