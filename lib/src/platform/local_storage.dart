import 'dart:convert';
import 'dart:io';
import '../models/deck.dart';
import '../util/deck_json_conversion.dart';

class LocalStorage {

  static File jsonFile;
  static Directory dir;
  static String fileName = "interleafStorage.json";
  static bool fileExists = false;
  static Map<String, dynamic> fileContent;

  static List<Deck> tempDecks;

  static void resetDecksFile(List<Deck> decks) {
    List<Map<String, dynamic>> decksContent = DeckJsonConversion.decksToJson(decks);
    tempDecks = decks;
    writeToFile("decks", decksContent);
  }

  static Map<String, dynamic> writeToFile(String key, dynamic value) {
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
    fileContent = json.decode(jsonFile.readAsStringSync());
    print("Writen to file! $fileContent");
    return fileContent;
  }

  static void createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  static void deleteFile() {
    if (fileExists == true) {
      print("Deleting file");
      jsonFile.deleteSync();
      fileContent = null;
      fileExists = false;
    }
  } 

  static void refreshFile() {
    List<Map<String, dynamic>> decksContent = DeckJsonConversion.decksToJson(tempDecks);
    writeToFile("decks", decksContent);
  }

}