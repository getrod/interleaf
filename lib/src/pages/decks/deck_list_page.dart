import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'deck_page.dart';
import '../../models/deck.dart';
import '../../util/deck_json_conversion.dart';
import '../../platform/local_storage.dart';

class DeckListPage extends StatefulWidget {
  final List<Deck> decks = [];
  @override
  State<StatefulWidget> createState() {
    return _DeckListPageState();
  }
}


class _DeckListPageState extends State<DeckListPage> {

  final textController = TextEditingController();

  @override
  void initState() {
    //super.initState();
    
    getApplicationDocumentsDirectory().then((Directory directory) {
      LocalStorage.dir = directory;
      LocalStorage.jsonFile = File(LocalStorage.dir.path + "/" + LocalStorage.fileName);
      LocalStorage.fileExists = LocalStorage.jsonFile.existsSync();
      if (LocalStorage.fileExists) {
        LocalStorage.fileContent = json.decode(LocalStorage.jsonFile.readAsStringSync());
        List<Deck> fileDecks = DeckJsonConversion.jsonToDecks(LocalStorage.fileContent["decks"]);
        //Remove broken cards from file (cards with missing images)
        for (int i = 0; i < fileDecks.length; i++) {
          fileDecks[i].removeBrokenCards();
        }
        LocalStorage.resetDecksFile(fileDecks);
        setState(() {
          widget.decks.clear();
          print("Init state: ${LocalStorage.fileContent}");
          widget.decks.addAll(fileDecks);
        });
        LocalStorage.tempDecks = widget.decks;
      } else {
        LocalStorage.resetDecksFile([]);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Widget build (context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createDeckPopup,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.create_new_folder),
      ),
      body: Center(
        child: createDeckButtonList(),
      ),
    );
  }

  Widget createDeckButtonList() {
    if (widget.decks.isEmpty){
      return Container (
        alignment: Alignment.center,
        margin: EdgeInsets.all(24),
        child: Text("NO DECKS",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.orange[900],
            fontSize: 15,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: widget.decks.length,
        itemBuilder: (context, int index) {
          return Container (
            margin: EdgeInsets.only(top: 24.0, left: 20, right: 20,),
            child: createDeckButton(widget.decks[index]),
          );
        },
      );
    }
  }

  Widget createDeckButton(Deck deck) {
    return ButtonTheme(
      height: 55,
      child: RaisedButton(
        onPressed: () async {
          Deck changedDeck = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeckPage(deck)),
          );
          setState(() {
            if (changedDeck != null) {
              if (changedDeck.delete == true) {
                widget.decks.remove(changedDeck);
                changedDeck.deleteDeck();
                LocalStorage.refreshFile();
              }              
            }
          });
          
        },
        elevation: 5,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.folder, color: Colors.orange[900],),
            ),
            Text(deck.deckName, style: TextStyle(color: Colors.orange[900], fontSize: 16),),
          ],
        ),
      ),
    );
  }

  Future<void> createDeckPopup() {
    textController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Deck'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: textController,
                  cursorColor: Colors.orange[900],
                  decoration: InputDecoration(
                    hintText: 'Enter deck name'
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('CREATE'),
              onPressed: () {
                if (textController.text.isEmpty)
                  return;
                //Add deck info to json file 
                //Add deck to list of decks 
                setState(() {
                  widget.decks.add(Deck.all(
                    textController.text,
                    id: 1,
                    cards: []
                  ));
                });
                
                LocalStorage.resetDecksFile(widget.decks);

                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


