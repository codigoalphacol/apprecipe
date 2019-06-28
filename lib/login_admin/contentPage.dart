// import 'package:recipes/pages/admin/mostrar_pagina.dart';
// import 'package:recipes/pages/maps_page.dart';
// import 'package:recipes/pages/myrecipes/mylist_myrecipe.dart';

 import 'package:recipes/widgets/home_page.dart';

abstract class Content {


   Future<HomePageRecipes> lista(); 
  // Future<InicioPage>  recetas(String id);
  // Future<MapsPage> mapa(); 
  // Future<ListMyrecipe> myrecipe(String id);
  // Future<InicioPage> admin();

 }


 class ContentPage implements Content {

   Future<HomePageRecipes> lista() async {
    return HomePageRecipes();
  }

  //  Future<MapsPage> mapa() async {
  //   return MapsPage();
  // }
  

  // Future<InicioPage> admin() async {
  //   return InicioPage();
  // }


  // Future<InicioPage> recetas(String id ) async {
  //   print('en content page $id'); 
  //   return InicioPage(id: id,);
  // }

  // Future<ListMyrecipe> myrecipe(String id ) async {
  //   print('listados mis recetas $id'); 
  //   return ListMyrecipe(id: id,);
  // }

 }