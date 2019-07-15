import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:recipes/auth/auth.dart';
import 'package:recipes/model/recipe_model.dart';
import 'package:recipes/pages/myrecipes/add_my_recipe.dart';
import 'package:recipes/pages/myrecipes/edit_my_recipe.dart';
import 'package:recipes/pages/myrecipes/view_my_recipe.dart';


class CommonThings {
  static Size size;
}

TextEditingController phoneInputController;
TextEditingController nameInputController;
String id;
final db = Firestore.instance;
String name;


class ListMyRecipe extends StatefulWidget {

  final String id;

  ListMyRecipe({this.auth, this.onSignedOut, this.id});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _ListMyRecipeState createState() => _ListMyRecipeState();
}

class _ListMyRecipeState extends State<ListMyRecipe> {


   String userID;
  //Widget content;

  @override
  void initState() {
    super.initState();

    setState(() {
      Auth().currentUser().then((onValue) {
        userID = onValue;
        print('el futuro Cheft $userID');
      });
    });
  }


  @override
  Widget build(BuildContext context) {
     CommonThings.size = MediaQuery.of(context).size;
    return new Scaffold(      
      body: StreamBuilder(
        stream: Firestore.instance.collection('usuarios').document(widget.id).collection('mycolrecipes').snapshots(),
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
                            '\nAdd my recipe.\n',
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditMyRecipe(
                                          recipe: recipe,
                                          idRecipe: document.documentID,
                                          uid: userID)));
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            //eliminamos la receta personal
                            document.data.remove('key');
                            Firestore.instance
                                .collection('usuarios/$userID/mycolrecipes')
                                .document(document.documentID)
                                .delete();
                                //eliminamos la foto
                            FirebaseStorage.instance
                                .ref()
                                .child(
                                    'usuarios/$userID/mycolrecipes/${document['name'].toString()}.jpg')
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
                            Recipe myrecipe = Recipe(
                              name: document['name'].toString(),
                              image: document['image'].toString(),
                              recipe: document['recipe'].toString(),
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewMyRecipe(
                                        recipe: myrecipe,
                                        idRecipe: document.documentID,
                                        uid: userID)));
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
          Route route = MaterialPageRoute(builder: (context) => MyAddRecipe());
          Navigator.push(context, route);
        },
      ),
    );
  }
}
