import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';
import '../models/index_card.dart';


class Home extends StatefulWidget {
  @override
  State createState() => new HomeState();
}

class HomeState extends State<Home> {

  TextEditingController keyInputController = new TextEditingController();
  TextEditingController valueInputController = new TextEditingController();

  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";
  bool fileExists = false;
  Map<String, dynamic> fileContent;



  var deck2 = Deck.all(
    "Deck #2",
    id: 2,
    cards: [],
  );

  List<Deck> decks = [];

  List<Map<String, dynamic>> decksContent;

  List< Map<String, dynamic>> decksToJson (List<Deck> decks) {
    List<Map<String, dynamic>> content = []; 
    
    for (int i = 0; i < decks.length; i++) {
      content.add(deckJson(decks[i]));
    }

    return content;
  }

  Map<String, dynamic> deckJson(Deck deck) {
    Map<String, dynamic> content = {
      "deckID": deck.id,
      "deckName": deck.deckName,
      "cards" : cardsJson(deck.cards),
    };
    return content;
  }
  
  List<Map<String, dynamic>> cardsJson(List<IndexCard> cards) {
    List<Map<String, dynamic>> content = [];    
    
    for (int i = 0; i < cards.length; i++) {
      Map<String, dynamic> card = {
        //"cardID": cards[i].id,
      };
      content.add(card);
    }
    return content;
  }


  @override
  void initState() {
    super.initState();
    decksContent = decksToJson(decks);
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    });
  }

  @override
  void dispose() {
    keyInputController.dispose();
    valueInputController.dispose();
    super.dispose();
  }

  void createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void writeToFile(String key, dynamic value) {
    print("Writing to file!");
    Map<String, dynamic> content = {key: value};
    if (fileExists) {
      print("File exists");
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
  }

    void writeMapToFile(Map<String, dynamic> content) {
    print("Writing to file!");
    if (fileExists) {
      print("File exists");
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
  }

  void deleteFile() {
    if (fileExists == true) {
      print("Deleting file");
      setState(() {
        jsonFile.deleteSync();
        fileContent = null;
        fileExists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("JSON Tutorial"),),
      body: new Column(
        children: <Widget>[
          new Padding(padding: new EdgeInsets.only(top: 10.0)),
          new Text("File content: ", style: new TextStyle(fontWeight: FontWeight.bold),),
          new Text(fileContent.toString()),
          new Padding(padding: new EdgeInsets.only(top: 10.0)),
          new Text("Add to JSON file: "),
          new TextField(
            controller: keyInputController,
          ),
          new TextField(
            controller: valueInputController,
          ),
          new Padding(padding: new EdgeInsets.only(top: 20.0)),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text("Add key, value pair"),
                onPressed: () {
                  Map<String, dynamic> testContent = {"card": []};
                  writeToFile("decks", decksContent);
                } 
              ),
              RaisedButton(
                child: new Text("Delete JSON file"),
                onPressed: () => deleteFile(),
              ),

            ],

          ),

        ],
      ),
    );
  }
}