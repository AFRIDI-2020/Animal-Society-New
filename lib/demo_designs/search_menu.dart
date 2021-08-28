import 'package:pet_lover/model/search_menu_item.dart';

class SearchMenu {
  static const List<SearchMenuItem> searchMenuList = [
    tokenSearch,
    animalNameSearch,
  ];
  static const tokenSearch = SearchMenuItem(text: 'Token');
  static const animalNameSearch = SearchMenuItem(text: 'Animal name');
}
