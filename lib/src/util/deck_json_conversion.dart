import '../models/deck.dart';
import '../models/index_card.dart';

class DeckJsonConversion {
  
  static List<Map<String, dynamic>> cardsToJson(List<IndexCard> cards) {
    List<Map<String, dynamic>> content = [];    
    for (int i = 0; i < cards.length; i++) {
      Map<String, dynamic> card = {
        "frontImageFile": cards[i].frontImage.path,
        "backImageFile": cards[i].backImage.path,
        "pScore": cards[i].pScore,
      };
      content.add(card);
    }
    return content;
  }

  
  static Map<String, dynamic> deckToJson(Deck deck) {
    Map<String, dynamic> content = {
      "deckID": deck.id,
      "deckName": deck.deckName,
      "cards" : cardsToJson(deck.cards),
    };
    return content;
  }

  static List< Map<String, dynamic>> decksToJson(List<Deck> decks) {
    List<Map<String, dynamic>> content = []; 
    
    for (int i = 0; i < decks.length; i++) {
      content.add(deckToJson(decks[i]));
    }

    return content;
  }

  static List<Deck> jsonToDecks(List<dynamic> content) {
    List<Deck> decks = [];
    for (int i = 0; i < content.length; i++) {
      Map<String, dynamic> newMap = content[i];
      Deck newDeck = Deck.fromJson(newMap);
      decks.add(newDeck);
    }
    return decks;
  }

  static List<IndexCard> jsonToIndexCards(List<dynamic> content) {
    List<IndexCard> cards = [];
    for (int i = 0; i < content.length; i++) {
      Map<String, dynamic> newMap = content[i];
      IndexCard newDeck = IndexCard.fromJson(newMap);
      cards.add(newDeck);
    }
    return cards;
  }


}