import 'package:flutter/material.dart';
import 'card_edit_page.dart';
import '../../platform/local_storage.dart';
import '../../models/index_card.dart';
import '../../models/deck.dart';

enum Options { rename, delete }

class DeckPage extends StatefulWidget {
  final Deck deck;
  DeckPage(this.deck);

  @override 
  State<StatefulWidget> createState() {
    return _DeckPageState();
  }
}

class _DeckPageState extends State<DeckPage> {
  
  final textController = TextEditingController();

  Widget build (context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[900],
        title: Text(widget.deck.deckName),
        actions: <Widget>[
          PopupMenuButton<Options>(
            onSelected: (Options result) { 
              if (result == Options.rename) {
                //Rename deck popup and refresh deck page
                _renamePopup();
              } else {
                //Ask are you sure, If yes, Delete deck and pop to deck list page
                _deletePopup();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
              const PopupMenuItem<Options>(
                value: Options.rename,
                child: Text('Rename Deck'),
              ),
              const PopupMenuItem<Options>(
                value: Options.delete,
                child: Text('Delete Deck'),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          IndexCard newIndexCard = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardEditPage(IndexCard())),
          );
          setState(() {
            //if card not null, add the index card to deck
            if (newIndexCard != null) {
              widget.deck.cards.add(newIndexCard);
              //refresh file 
              LocalStorage.refreshFile();             
            }
          });
        },
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.library_add),
      ),
      body:  Center(
        child: createIndexCardList(),
      ),
    );
  }
  
    Widget createIndexCardList() {
    if (widget.deck.cards.isEmpty){
      return Container (
        alignment: Alignment.center,
        margin: EdgeInsets.all(24),
        child: Text("No Cards"),
      );
    } else {
      return ListView.builder(
        itemCount: widget.deck.cards.length,
        itemBuilder: (context, int index) {
          return Container (
            margin: EdgeInsets.only(top: 24.0, left: 20, right: 20,),
            child: createIndexCardButton(widget.deck.cards[index]),
          );
        },
      );
    }
  }

  Widget createIndexCardButton(IndexCard card) {
    return ButtonTheme(
      height: 150,
      child: RaisedButton(
        elevation: 5,
        color: Colors.white,
        onPressed: () async {
          IndexCard newIndexCard = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardEditPage(card)),
          );
          setState(() {
            if (newIndexCard != null) {
              if (newIndexCard.delete == true) {
                newIndexCard.deleteIndexCard();
                widget.deck.cards.remove(newIndexCard);
              }
            }
          });
          LocalStorage.refreshFile();
        },
        child: Image.file(card.frontImage),
      ),
    );
  }

  Future<void> _renamePopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Deck'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: textController,
                  cursorColor: Colors.orange[900],
                  decoration: InputDecoration(
                    hintText: 'Enter new deck name'
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('RENAME'),
              onPressed: () {
                setState(() {
                  widget.deck.deckName = textController.text;
                  LocalStorage.refreshFile();
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('CANCEL'),
              onPressed: () {
                textController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("All cards in this deck will be deleted forever. Are you sure?",),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('YES'),
              onPressed: () {
                widget.deck.delete = true;
                Navigator.pop(context);
                Navigator.pop(context, widget.deck);
              },
            ),
          ],
        );
      },
    );
  }  
}

