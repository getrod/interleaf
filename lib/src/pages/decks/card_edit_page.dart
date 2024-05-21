import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/index_card.dart';

enum Options {delete, picSet}

class CardEditPage extends StatefulWidget {
  final IndexCard card;
  CardEditPage(this.card);
  createState() {
    return _CardEditPageState();
  }
}

class _CardEditPageState extends State<CardEditPage> {
  String directionName = "Front";
  bool isFront = true;
  File _image;
  File frontImage;
  File backImage;
  bool newCard = false;
  bool cancel = false;
  String picSetting = 'g';

  Widget centerCard;
  Function deleteButtonFunction;

  static const platform = const MethodChannel('com.interleaf.platform');

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("In getImage(): "+image.path);
      setState(() {
        _image = image;
      });
    }

  } 

  //Send image path to palform
  Future<bool> trasformImageToIndexCard(File image) async {
    String platformMessage = 'No Message';
    bool result = false;
    print("In trasformImageToIndexCard(): " + image.path);
    try {
      result = await platform.invokeMethod('createIndexCard', {'path': image.path, 'picSetting': picSetting});
      platformMessage = 'Message is: $result ';
      print(platformMessage);
    } on PlatformException catch (e) {
      platformMessage = "Failed to get Message: '${e.message}'.";
      print(platformMessage);
      result = false;
    }
    
    if (result == true) {
      // Show confermation page
      print("Index Card has been made");
    } else {
      print("Cannot make Index Card");
      image.delete();
      detectionErrorPopup();
    }

    return result;

  }

  @override
  void dispose() {
    //if (newCard) {
      //If IndexCard only has one completed side, and user dismisses state,
      //throw away new card.
      // if (frontImage != null && backImage == null) {
      //   frontImage.delete();
      // }
      // if (frontImage == null && backImage != null) {
      //   backImage.delete();
      // }
      // if (frontImage != null) {frontImage.delete();}
      // if (backImage != null) {backImage.delete();}
    //}

    if (cancel == false && newCard == false) {
      print("Card getting deleted");
      print('cancel: $cancel');
      print('newCard: $newCard');
      if (frontImage != null) {frontImage.delete();}
      if (backImage != null) {backImage.delete();}
    }

    if (cancel == false && newCard == true) {
      print("Card getting deleted");
      print('cancel: $cancel');
      print('newCard: $newCard');
      if (frontImage != null) {frontImage.delete();}
      if (backImage != null) {backImage.delete();}
    }


    super.dispose();
  }

  @override
  initState() {
    super.initState();
    if (widget.card.frontImage != null && widget.card.backImage != null) {
      //frontImage = File(widget.card.frontImagePath);
      //backImage = File(widget.card.backImagePath);
      frontImage = widget.card.frontImage;
      backImage = widget.card.backImage;
      centerCard = Image.file(frontImage);
      deleteButtonFunction = removeFrontImage;
    } else {
      newCard = true;
      centerCard = createIndexCardButton(isFront);
    }
  }

  

  Widget build(context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[900],
          elevation: 0.0,
          title: Text("New Card"),
          actions: <Widget>[
            PopupMenuButton<Options>(
              onSelected: (Options result) { 
                if (result == Options.delete) {
                  _deleteCardPopup();
                }
                if (result == Options.picSet) {
                  picSettingPopup();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
                const PopupMenuItem<Options>(
                  value: Options.delete,
                  child: Text('Delete Card'),
                ),
                const PopupMenuItem<Options>(
                  value: Options.picSet,
                  child: Text('Photo Color'),
                ),
              ],
            )
          ],
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: [
                //Delete Button, Card Direction Name, Flip Card Button
                Flexible(
                  flex: 1,
                  child: Container (
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        //Delete Button
                        FlatButton(
                          child: Icon(Icons.clear, color: Colors.orange[900],),
                          onPressed: deleteButtonFunction
                        ),

                        //Card Direction Name
                        Text(
                          directionName, 
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        //Flip Card Button
                        FlatButton(
                          child: Icon(Icons.autorenew, color: Colors.orange[900],),
                          onPressed: () {
                            setState(() {
                              if (isFront == true) {
                                directionName = "Back";
                                isFront = false;
                                print("Flip BackImage: " + backImage.toString());
                                if(backImage != null) {
                                  centerCard = Image.file(backImage);
                                  deleteButtonFunction = removeBackImage;
                                } else {
                                  centerCard = createIndexCardButton(isFront);
                                  deleteButtonFunction = null;
                                }
                              } else {
                                directionName = "Front";
                                isFront = true;
                                print("Flip FrontImage: " + frontImage.toString());
                                if(frontImage != null) {
                                  centerCard = Image.file(frontImage);
                                  deleteButtonFunction = removeFrontImage;
                                } else {
                                  centerCard = createIndexCardButton(isFront);
                                  deleteButtonFunction = null;
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                //Center Card (Defult: Index Button)
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: centerCard,
                ),

                //Save and Cancel Buttons
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        //Save Button
                        ButtonTheme (
                          minWidth: 130.0,
                          height: 50.0,
                          buttonColor: Colors.white,
                          child: RaisedButton(
                            child: Text("SAVE", style: TextStyle(color: Colors.orange[900]),),
                            onPressed: saveFunction,
                          ),
                        ),

                        //Cancel Button
                        ButtonTheme (
                          minWidth: 130.0,
                          height: 50.0,
                          buttonColor: Colors.white,
                          child: RaisedButton(
                            child: Text("CANCEL", style: TextStyle(color: Colors.orange[900]),),
                            onPressed: () {
                              if (newCard) {
                                cancel = true;
                                if (frontImage != null){frontImage.delete();}
                                if (backImage != null){backImage.delete();}
                                Navigator.of(context).pop(null);
                              } else {
                                //if front or back image null
                                //then ask are u sure u wanna cancel
                                //Your card is missing an image
                                //If you cancel, your entire card will be deleted
                                if (frontImage == null || backImage == null) {
                                  cancelPopup();
                                } else {
                                  cancel = true;
                                  Navigator.of(context).pop();
                                }
                                
                              }
                            },
                          ),
                        ),
                    ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    
  }

  Future<bool> onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('You did not save!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Save this card to exit.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.orange[900],
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('OK'),
          ),
          // FlatButton(
          //   onPressed: (){
          //     if (newCard) {
          //       if (frontImage != null){frontImage.delete();}
          //       if (backImage != null){backImage.delete();}
          //     }
          //     //if f null or b null: cancel popup
          //     if (frontImage == null || backImage == null) {
          //       widget.card.delete = true;
          //     }
          //     Navigator.of(context).pop(true);
          //     //Navigator.pop(context, widget.card);
          //   }, 
          //   child: Text('Yes'),
          // ),
        ],
      ),
    ) ?? false;
  }

  Future<void> picSettingPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose picture setting'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //Text("This card will be deleted forever. Are you sure?",),
                //Defult (Black & White): 'd'
                RaisedButton(
                  onPressed: (){
                    picSetting = 'd';
                    Navigator.pop(context);
                  },
                  child: Text("Defult (Black & White)"),
                ),
                //Greyscale : 'g'
                RaisedButton(
                  onPressed: (){
                    picSetting = 'g';
                    Navigator.pop(context);
                  },
                  child: Text("Greyscale"),
                ),                
                //Color : 'c'
                RaisedButton(
                  onPressed: (){
                    picSetting = 'c';
                    Navigator.pop(context);
                  },
                  child: Text("Color"),
                ),                  
              ],
            ),
          ),
          actions: <Widget>[
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

  Future<void> _deleteCardPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("This card will be deleted forever. Are you sure?",),
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
                if (newCard) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  widget.card.delete = true;
                  cancel = true;
                  Navigator.pop(context);
                  Navigator.pop(context, widget.card);
                }
              },
            ),
          ],
        );
      },
    );
  }  

  void saveFunction() {
    if (frontImage != null && backImage != null) {
      cancel = true;
      widget.card.frontImage = frontImage;
      widget.card.backImage = backImage;
      print("Save funciton: " +widget.card.frontImage.toString());
      Navigator.of(context).pop(widget.card);
    } else {
      print("saveErrorPopUp");
      saveErrorPopup();
    }
  }

  Widget createIndexCardButton(bool isFront) {
    
    return ButtonTheme(
      minWidth: double.infinity,
      buttonColor: Colors.white,
      child: RaisedButton(
        elevation: 10,
        child: Icon(Icons.add_a_photo, color: Colors.orange[900]),
        onPressed: () async {
          await getImage();
          print("after getImage method");
          print(_image);
          if (_image != null) {
            bool result = await trasformImageToIndexCard(_image);
            if (result) {
              setState(() {
                if (isFront) {
                  frontImage = _image;
                  centerCard = Image.file(frontImage);
                  deleteButtonFunction = removeFrontImage;
                } else {
                  backImage = _image;
                  centerCard = Image.file(backImage);
                  deleteButtonFunction = removeBackImage;
                }
              });
            }
            
          }
          _image = null;
        },
      ),
    );
  }

  void removeFrontImage() async {
    await deleteImagePopup(frontImage);
    if (!frontImage.existsSync()) {frontImage = null;}
    print("Frontimage: " + frontImage.toString());
  }

  void removeBackImage() async {
    await deleteImagePopup(backImage);
    if (!backImage.existsSync()) {backImage = null;}
    print("Backimage: " + backImage.toString());
  }

  Future<void> deleteImagePopup(File image) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $directionName image?'),
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
                image.delete();
                setState(() {
                  centerCard =  createIndexCardButton(isFront);
                  deleteButtonFunction = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to cancel?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Your card is missing an image.",),
                Text("If you cancel, your entire card will be deleted!",),
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
                cancel = true;
                widget.card.delete = true;
                Navigator.of(context).pop();
                Navigator.pop(context, widget.card);
              },
            ),
          ],
        );
      },
    );
  } 

    Future<void> detectionErrorPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Could not find index card!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Ensure that all four tags on the index card are visible in the image.",),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveErrorPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You are missing an image!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("You can't save this card when one side is missing an image.",),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.orange[900],
              child: Text('OK'),
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

