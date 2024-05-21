import 'package:flutter/material.dart';
import 'package:interleaf/src/platform/local_storage.dart';
import 'package:interleaf/src/models/deck.dart';
import 'package:interleaf/src/models/index_card.dart';
import 'package:photo_view/photo_view.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Item> _data;

  @override
  void initState() {
    _data = generateItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue, style: TextStyle(color: Colors.orange[900], 
              fontWeight: FontWeight.bold),),
            );
          },
          body: item.body,
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  List<Item> generateItems() {
    return List.generate(LocalStorage.tempDecks.length, (int index) {
      return Item(
        headerValue: '${LocalStorage.tempDecks[index].deckName}',
        body: Container(
          padding: EdgeInsets.all(16),
          child: cardInfoList(LocalStorage.tempDecks[index]),
        ),
      );
    });
  }


  Widget cardInfoList(Deck deck) {
    Deck.sortCardsByPScore(deck);
    return Column(
      children: columns(deck.cards),
    );
  }

  List<Column> columns(List<IndexCard> cards) {
    List<Column> columns = List<Column>.generate(cards.length, (int index) {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ButtonTheme(
                minWidth: 15,
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardStatPage(cards[index])),
                      );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 100.0,
                      maxWidth:  100.0,
                      minWidth: 50.0,
                      minHeight: 50.0
                    ),
                    color: Colors.amber,
                    child: Image.file(cards[index].frontImage, fit: BoxFit.contain,),
                  ),
                ),
              ),
              
              Spacer(),
              Flexible(
                fit: FlexFit.loose,
                flex: 7,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  value: cards[index].pScore*(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor(cards[index].pScore)),
                ), 
              ),
            ],
          ),
          Divider(),
        ]
      );
    });
    return columns;
  }
}

class Item {
  Item({
    this.headerValue,
    this.body,
    this.isExpanded = false,
  });

  String headerValue;
  Widget body;
  bool isExpanded;
}

scoreColor(double pScore) {
  if(pScore == 1.0) {return Colors.red;}
  else if(pScore == 2.0) {return Colors.lime[300];}
  else if(pScore == 3.0) {return Colors.green[300];}
  else if(pScore == 4.0) {return Colors.green;}
  else {return Colors.white;}
}



class CardStatPage extends StatelessWidget {
  final IndexCard card;

  CardStatPage(this.card);

  final textStyle = TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold,
    fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[900],
        title: Text("Card Stats"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Spacer(flex: 3,),
            //Score
            Text('SCORE: ${card.pScore}', style: textStyle,),
            Flexible(
              fit: FlexFit.loose,
              flex: 7,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  value: card.pScore*(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor(card.pScore)),
                ),
              ),
            ),
            //Space
            Spacer(flex: 2,),
            //Front
            Text('FRONT', style: textStyle,),
            Container(
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoView(
                      imageProvider: FileImage(card.frontImage),
                    )),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Colors.grey)
                  ),
                  child: Image.file(card.frontImage),
                ),
              ),
            ),
            
            Spacer(flex: 2,),    
            //Back
            Text('BACK', style: textStyle,),
            Container(
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoView(
                      imageProvider: FileImage(card.backImage),
                    )),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Colors.grey)
                  ),
                  child: Image.file(card.backImage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}