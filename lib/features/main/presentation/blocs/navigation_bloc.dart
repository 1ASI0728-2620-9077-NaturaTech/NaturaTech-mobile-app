import 'package:flutter_bloc/flutter_bloc.dart';

enum NavbarItem { plants, iot, tasks, profile }

class NavigationBloc extends Cubit<NavbarItem> {
  NavigationBloc() : super(NavbarItem.plants);

  void changePage(NavbarItem item) => emit(item);
}