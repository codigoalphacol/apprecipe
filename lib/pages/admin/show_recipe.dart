import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:recipes/auth/auth.dart';
import 'package:recipes/model/recipe_model.dart';
import 'package:recipes/pages/admin/add_recipe.dart';
//import 'package:recipes/pages/admin/agregar_receta.dart';
//import 'package:recipes/pages/admin/recetasFormEdit.dart';
//import 'package:recipes/pages/admin/ver_receta.dart';


class CommonThings {
  static Size size;
}

TextEditingController nameInputController;
String id;
final db = Firestore.instance;
String name;


class InicioPage extends StatefulWidget {

  final String id;
  InicioPage({this.auth, this.onSignedOut, this.id});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {

   String userID;
  //Widget content;

  @override
  void initState() {
    super.initState();

    setState(() {
      Auth().currentUser().then((onValue) {
        userID = onValue;
        print('user id $userID');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CommonThings.size = MediaQuery.of(context).size;
    //print('Width of the screen: ${CommonThings.size.width}');
    return new Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection("colrecipes").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text("loading....");
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15),
                      shape: BeveledRectangleBorder(
                          side: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0)),
                      elevation: 5.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '\nAgrega un recipe.\n',
                            style: TextStyle(fontSize: 24, color: Colors.blue),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            } else {
              //print("from the streamBuilder: "+ snapshot.data.documents[]);
              // print(length.toString() + " doc length");

              return ListView(
                children: snapshot.data.documents.map((document) {
                  return Card(
                    elevation: 5.0,
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              placeholder: AssetImage('assets/images/azucar.gif'),
                              image: NetworkImage(document["image"]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              document['name'].toString().toUpperCase(),
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 17.0,
                              ),
                            ),
                            subtitle: Text(
                              document['recipe'].toString().toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black, fontSize: 12.0),
                            ),
                            //editar la receta
                            onTap: () {
                              Recipe recipe = Recipe(
                                name: document['name'].toString(),
                                image: document['image'].toString(),
                                recipe: document['recipe'].toString(),
                              );
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => RecipeFormEdit(
                              //             recipe: recipe,
                              //             idRecipe: document.documentID,
                              //             uid: userID)));
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            document.data.remove('key');
                            Firestore.instance
                                .collection('colrecipes')
                                .document(document.documentID)
                                .delete();
                            FirebaseStorage.instance
                                .ref()
                                .child(
                                    'colrecipes/$userID/uid/recipe/${document['name'].toString()}.jpg')
                                .delete()
                                .then((onValue) {
                              print('foto eliminada');
                            });
                          }, //funciona
                        ),
                        
                        IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: Colors.blueAccent,
                          ),
                          //Visualizar la receta,
                          onPressed: () {
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
                            //             idRecipe: document.documentID,
                            //             uid: userID)));
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          Route route = MaterialPageRoute(builder: (context) => MyAddPage());
          Navigator.push(context, route);
        },
      ),
    );
  }
}





