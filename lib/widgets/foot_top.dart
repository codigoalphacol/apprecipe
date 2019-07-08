import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipes/auth/auth.dart';
import 'package:recipes/model/recipe_model.dart';
//import 'package:recipes/pages/admin/ver_receta.dart';

class FoodTop extends StatefulWidget {
  @override
  _FoodTopState createState() => _FoodTopState();
}

class _FoodTopState extends State<FoodTop> {

  String userID;
  //Widget content;

  @override
  void initState() {
    super.initState();

    setState(() {
      Auth().currentUser().then((onValue) {
        userID = onValue;
        print('print userid $userID');
      });
    });
  }


  @override
  Widget build(BuildContext context) {
   var height = MediaQuery.of(context).size.height * 0.15; // set height to 40% of the screen height
    return  Container(
              height: height,
              width: double.infinity,
              color: Colors.black38,
              child: StreamBuilder(
                stream: Firestore.instance.collection("colrecipes").snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Text("loading....");
                  } else {
                    if (snapshot.data.documents.length == 0) {
                    } else {
                      return Container(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: snapshot.data.documents.map((document) {
                            return Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: (){
                                    Recipe recipe = Recipe(
                                          name: document['name'].toString(),
                                          image: document['image'].toString(),
                                          recipe: document['recipe'].toString(),
                                        );
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => VerReceta(
                                        //             recipe: recipe,
                                        //             idRecipe:
                                        //                 document.documentID,
                                        //             uid: userID)
                                        //             )
                                        //             );
                                  },
                                  child: Container(
                                    height: 100.0,
                                    margin: EdgeInsets.only(right: 20.0),
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                        child: Row(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: FadeInImage(
                                                fit: BoxFit.cover,
                                                width: 65,
                                                height: 65,
                                                placeholder: AssetImage(
                                                    'assets/images/azucar.gif'),
                                                image: NetworkImage(
                                                    document["image"]),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  document["name"].toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                  }
                },
              ),
            );
  }
}