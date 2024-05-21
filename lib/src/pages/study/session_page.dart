import 'dart:io';
import 'package:flutter/material.dart';
import 'package:interleaf/src/models/deck.dart';
import 'package:interleaf/src/platform/local_storage.dart';
import 'package:photo_view/photo_view.dart';

/*
  1. Tap Card image to go photo_view: https://pub.dev/packages/photo_view
  2. Show answer functionality
  3. Save pScore to jSon
 */

class StudySessionPage extends StatefulWidget {
  final Deck studyDeck;
  StudySessionPage(this.studyDeck);
  @override
  _StudySessionPageState createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  Widget belowCardArea;
  Widget aboveCardArea;
  File currentImage;
  String text = "";
  int counter = 0;
  double sliderDelta = 0;
  double sliderValue = 0;

  @override
  void initState() {
    print(widget.studyDeck.toString());
    belowCardArea = showAnswerButton();
    aboveCardArea = Spacer();
    currentImage = widget.studyDeck.cards[counter].frontImage;
    sliderDelta = 1 / widget.studyDeck.cards.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Study Session'),
          backgroundColor: Colors.orange[900],
        ),

        body: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white30,
                value: sliderValue,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),  
            ),

            aboveCardArea,

            Flexible(
              flex: 7,
              child: Container(
                alignment: Alignment.center,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PhotoView(
                        imageProvider: FileImage(currentImage),
                      )),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.grey)
                    ),
                    child: Image.file(currentImage),
                  ),
                ),
              ),
            ),

            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Text(text, style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),),
              ),
            ),

            Flexible(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.topCenter,
                child: belowCardArea,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit the Study Session'),
        actions: <Widget>[
          new FlatButton(
            textColor: Colors.orange[900],
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            textColor: Colors.orange[900],
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget showAnswerButton() {
    return ButtonTheme(
      height: 80,
      minWidth: double.infinity,
      child: RaisedButton(
        color: Colors.orange[900],
        onPressed: (){
          // switch belowCardArea to have the card evaluation widget
          // change current image to backImage
          setState(() {
            belowCardArea = evaluationButtons();
            currentImage = widget.studyDeck.cards[counter].backImage;
            text = "HOW'D YOU DO?";
            aboveCardArea = ButtonTheme(
              child: FlatButton(
                //color: Colors.orange[900],
                onPressed: (){
                  setState(() {
                    if (currentImage == widget.studyDeck.cards[counter].frontImage) {
                      currentImage = widget.studyDeck.cards[counter].backImage;
                    } else {
                      currentImage = widget.studyDeck.cards[counter].frontImage;
                    }
                  });
                },
                child: Icon(Icons.autorenew, color: Colors.orange[900],),
              ) ,
            );
          });
        },
        child: Text("SHOW ANSWER", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget evaluationButtons() {
    //Increament counter for for next card image and slider
    return Column(
      children: <Widget>[
        GridView.count(
          shrinkWrap: true,
          primary: false,
          crossAxisCount: 4,
          children: <Widget>[
            Container(
              color: Colors.amber, 
              margin: EdgeInsets.all(4),
              child: ButtonTheme(
                height: 10,
                minWidth: 150,
                child: FlatButton(
                  onPressed: (){
                    evalButton(1);
                  },
                  child: Icon(Icons.sentiment_dissatisfied, color: Colors.white,),
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              color: Colors.amber, 
              margin: EdgeInsets.all(4),
              child: ButtonTheme(
                height: 10,
                minWidth: 150,
                child: FlatButton(
                  onPressed: (){
                    evalButton(2);
                  },
                  child: Icon(Icons.sentiment_neutral, color: Colors.white,),
                  color: Colors.lime,
                ),
              ),
            ),
            Container(
              color: Colors.amber, 
              margin: EdgeInsets.all(4),
              child: ButtonTheme(
                height: 10,
                minWidth: 150,
                child: FlatButton(
                  onPressed: (){
                    evalButton(3);
                  },
                  child: Icon(Icons.sentiment_satisfied, color: Colors.white,),
                  color: Colors.green[300],
                ),
              ),
            ),
            Container(
              color: Colors.amber, 
              margin: EdgeInsets.all(4),
              child: ButtonTheme(
                height: 10,
                minWidth: 150,
                child: FlatButton(
                  onPressed: (){
                    evalButton(4);
                  },
                  child: Icon(Icons.sentiment_very_satisfied, color: Colors.white,),
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    
    

  }

  void evalButton(double pScore) {
    //If its a good score rating
    if (pScore > 2) {
      if (widget.studyDeck.cards[counter].repeat == true) {
        //Don't save its current score
        //Just incrament counter to go to next card
      } else {
        //Save new pScore to the card
        widget.studyDeck.cards[counter].pScore = pScore;
        LocalStorage.refreshFile();
      }
      setState(() {
        sliderValue += sliderDelta; 
        counter++;
      });

    } else {
      //If card scores poorly, repeat is true
      widget.studyDeck.cards[counter].repeat = true;
      //Save that card's new low score
      widget.studyDeck.cards[counter].pScore = pScore;
      LocalStorage.refreshFile();
      //Place card randomly back in deck
      Deck.insertCardRandomlyBackInDeck(widget.studyDeck, widget.studyDeck.cards[counter], counter);
    }



    // //Assign score to card
    // widget.studyDeck.cards[counter].pScore = pScore;
    // //Save file
    // LocalStorage.refreshFile();


    //Incrament counter
    // counter++;
    //if there are more cards, send next card
    if (counter < widget.studyDeck.cards.length) {
      setState(() { 
        belowCardArea = showAnswerButton();
        currentImage = widget.studyDeck.cards[counter].frontImage;
        text = "";
        aboveCardArea = Spacer();        
      });
    }

    //else, show completion page 
    else {
      //reset all repeat values of cards back to false
      for (int i = 0; i < widget.studyDeck.cards.length; i++) {
        widget.studyDeck.cards[i].repeat = false;
      }
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _SessionCompletionPage()),
      );      
    }
  }

}

class _SessionCompletionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Container(),
            ),
            //Congrats text
            Text(
              "GREAT JOB!!", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.orange[900],
                fontSize: 20,
              ),
            ),
            Text(
              "You have finshed this study session.", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.orange[900].withOpacity(.7),
                fontSize: 15
              ),
            ),
            Spacer(),
            //Button to return to study screen
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ButtonTheme(
                height: 70,
                minWidth: double.infinity,
                child: RaisedButton(
                  color: Colors.orange[900],
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("RETURN TO STUDY HOMEPAGE", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            Flexible(
              flex: 3,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
