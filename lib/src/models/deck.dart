import 'dart:math';
import 'index_card.dart';
import '../util/deck_json_conversion.dart';

class Deck {
  String deckName;
  List<IndexCard> cards = [];
  int id;
  bool delete = false;

  Deck(this.deckName);

  Deck.all(this.deckName, {this.id, this.cards});

  Deck.fromJson(Map<String, dynamic> parsedJson) {
    deckName = parsedJson["deckName"];
    id = parsedJson["deckID"];
    cards = DeckJsonConversion.jsonToIndexCards(parsedJson["cards"]);
  }

  void deleteDeck() {
    if (cards != null) {
      for (int i = 0; i < cards.length; i++) {
        cards[i].deleteIndexCard();
      }
    }
  }

  void removeBrokenCards() {
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isBroken()) {
        cards[i].deleteIndexCard();
        cards.remove(cards[i]);
      }
    }
  }

  String toString() {
    String cardsString = '';
    for (int i = 0; i < cards.length; i++) {
      cardsString += cards[i].toString() + '\n';
    }
    return 'Deck Name: $deckName \ncards: $cardsString';
  }

  //static: combine list of decks, spit back new deck
  static Deck mergeDecks(List<Deck> decks) {
    Deck mergedDeck = Deck("mergedDeck");
    for (int i = 0; i < decks.length; i++) {
      mergedDeck.cards.addAll(decks[i].cards);
    }
    return mergedDeck;
  }

  //static: shuffle deck cards based on pScore
  static void sortCardsByPScore(Deck deck) {
    // IndexCard card1 = IndexCard();
    // card1.pScore = 1;
    // IndexCard card2 = IndexCard();
    // card2.pScore = 2;
    // IndexCard card3 = IndexCard();
    // card3.pScore = 3;
    // IndexCard card4 = IndexCard();
    // card4.pScore = 4;

    // Deck testDeck = Deck.all("deckName", cards: [card2, card3, card1, card4], id:1 );
    // print("Before Sort \n");
    // print(testDeck.toString() + '\n');

    // //Sort from greatest to smallest
    // testDeck.cards.sort((a,b) => a.pScore.compareTo(b.pScore));
    // print("After sort \n");
    // print(testDeck);
    deck.cards.sort((a,b) => a.pScore.compareTo(b.pScore));
  }

  static void insertCardRandomlyBackInDeck(Deck deck, IndexCard card, int currentIndex) {
    deck.cards.remove(card);
    //Random int number between currentIndex and the length deck - 1
    var ran = Random();
    int min = currentIndex;
    int max = deck.cards.length + 1;
    int randomIndex = min + ran.nextInt(max - min);
    print('randomIndex: $randomIndex');
    print('max: $max');
    //Insert card at that index
    deck.cards.insert(randomIndex, card);
  }

}