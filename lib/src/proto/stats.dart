
import 'package:flutter/material.dart';
import 'package:interleaf/src/models/deck.dart';
import 'package:interleaf/src/models/index_card.dart';

var card1 = IndexCard.pScoreTest(1);
var card2 = IndexCard.pScoreTest(2);
var card3 = IndexCard.pScoreTest(3);
var card4 = IndexCard.pScoreTest(4);

List<IndexCard> cards = [
  card1,
  card2,
  card3,
  card4
];

List<Deck> decks = [
  Deck.all(
    "Deck #1",
    id: 1,
    cards: cards
  ),
  Deck.all(
    "Deck #2",
    id: 1,
    cards: [
      card2, card3, card3, card4, card1
    ]
  ),
];

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatefulWidget(),
      ),
    );
  }
}

// stores ExpansionPanel state information
class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.body,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  Widget body;
  bool isExpanded;
}

//Each panel will hold deck information
List<Item> generateItems(List<Deck> decks) {
  return List.generate(decks.length, (int index) {
    return Item(
      headerValue: '${decks[index].deckName}',
      expandedValue: decks[index].cards.toString(),
      body: Container(
        padding: EdgeInsets.all(16),
        child: cardInfoList(decks[index]),
      ),
    );
  });
}

Widget cardInfoList(Deck deck) {
  // return ListView.builder(
  //   shrinkWrap: true,
  //   itemCount: cards.length,
  //   itemBuilder: (context, count) {
  //     return Container(
  //       margin: EdgeInsets.symmetric(horizontal: 16.0),
  //       child: cardInfoSlot(cards[count]),
  //     );
  //   },
  // );
  Deck.sortCardsByPScore(deck);
  return Column(
    //list of coloms function
    children: columns(deck.cards),
  );
}

List<Column> columns(List<IndexCard> cards) {
  List<Column> columns = List<Column>.generate(cards.length, (int index) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              color: Colors.purple,
              onPressed: (){},
              child: Icon(Icons.ac_unit),
            ),
            //Text('${cards[index].pScore}'),
            Spacer(),
            Flexible(
              fit: FlexFit.loose,
              flex: 7,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white30,
                value: cards[index].pScore*(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
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

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  List<Item> _data = generateItems(decks);

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
              title: Text(item.headerValue),
            );
          },
          body: item.body,
          // body: ListTile(
          //     title: Text(item.expandedValue),
          //     subtitle: Text('To delete this panel, tap the trash can icon'),
          //     trailing: Icon(Icons.delete),
          //     onTap: () {
          //       setState(() {
          //         _data.removeWhere((currentItem) => item == currentItem);
          //       });
          //     }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}