import 'dart:io';

class IndexCard {
  String frontImagePath;
  String backImagePath;
  File frontImage;
  File backImage;
  bool delete = false;
  bool repeat = false;
  double pScore = 1;

  IndexCard({this.frontImagePath, this.backImagePath}) {
    if (frontImagePath != null && backImagePath != null) {
      frontImage = File(frontImagePath);
      backImage = File(backImagePath);
    }
  }
  IndexCard.fromJson(Map<String, dynamic> parsedJson){
    frontImagePath = parsedJson["frontImageFile"];
    backImagePath = parsedJson["backImageFile"];
    pScore = parsedJson["pScore"];
    frontImage = File(frontImagePath);
    backImage = File(backImagePath);
  }

  IndexCard.pScoreTest(this.pScore);

  bool isBroken() {
    if (frontImage.existsSync() == false || backImage.existsSync() == false) {
      print('Card Broken');
      return true;
    } else {
      return false;
    }
  }

  void deleteIndexCard(){
    //if frontImage && backImage not null
    //delete their files async
    if(frontImage != null && frontImage.existsSync()){frontImage.delete();}
    if(backImage != null && backImage.existsSync()){backImage.delete();}
  }

  String toString() {
    if(frontImage != null){frontImagePath = frontImage.path;}
    if(backImage != null){backImagePath = backImage.path;}
    return 'FrontImagePath: $frontImagePath \nBackImagePath: $backImagePath' +
    '\npScore: $pScore';
  }
}