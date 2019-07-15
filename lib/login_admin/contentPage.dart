import 'package:recipes/pages/admin/show_recipe.dart';
import 'package:recipes/pages/myrecipes/list_my_recipe.dart';
import 'package:recipes/widgets/home_page.dart';

abstract class Content {


   Future<HomePageRecipes> lista(); 
   Future<ListMyRecipe> myrecipe(String id);
  // Future<InicioPage>  recetas(String id);
  // Future<MapsPage> mapa(); 
   Future<InicioPage> admin();

 }


 class ContentPage implements Content {

   Future<HomePageRecipes> lista() async {
    return HomePageRecipes();
  }

  //  Future<MapsPage> mapa() async {
  //   return MapsPage();
  // }
  

  Future<InicioPage> admin() async {
    return InicioPage();
  }


  // Future<InicioPage> recetas(String id ) async {
  //   print('en content page $id'); 
  //   return InicioPage(id: id,);
  // }

  Future<ListMyRecipe> myrecipe(String id ) async {
    print('listados mis recetas $id'); 
    return ListMyRecipe(id: id,);
  }

 }
