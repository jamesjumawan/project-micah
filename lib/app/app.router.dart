// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i8;
import 'package:stacked/stacked.dart' as _i7;
import 'package:stacked_services/stacked_services.dart' as _i6;

import '../ui/views/categories/categories_view.dart' as _i3;
import '../ui/views/details/details_view.dart' as _i5;
import '../ui/views/home/home_view.dart' as _i2;
import '../ui/views/search/search_view.dart' as _i4;
import '../ui/views/startup/startup_view.dart' as _i1;

final stackedRouter = StackedRouterWeb(
  navigatorKey: _i6.StackedService.navigatorKey,
);

class StackedRouterWeb extends _i7.RootStackRouter {
  StackedRouterWeb({_i8.GlobalKey<_i8.NavigatorState>? navigatorKey})
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    StartupViewRoute.name: (routeData) {
      final args = routeData.argsAs<StartupViewArgs>(
        orElse: () => const StartupViewArgs(),
      );
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.StartupView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    HomeViewRoute.name: (routeData) {
      final args = routeData.argsAs<HomeViewArgs>(
        orElse: () => const HomeViewArgs(),
      );
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i2.HomeView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    CategoriesViewRoute.name: (routeData) {
      final args = routeData.argsAs<CategoriesViewArgs>(
        orElse: () => const CategoriesViewArgs(),
      );
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i3.CategoriesView(
          key: args.key,
          selectedCategory: args.selectedCategory,
        ),
        opaque: true,
        barrierDismissible: false,
      );
    },
    SearchViewRoute.name: (routeData) {
      final args = routeData.argsAs<SearchViewArgs>(
        orElse: () => const SearchViewArgs(),
      );
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i4.SearchView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    DetailsViewRoute.name: (routeData) {
      final args = routeData.argsAs<DetailsViewArgs>(
        orElse: () => const DetailsViewArgs(),
      );
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i5.DetailsView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(StartupViewRoute.name, path: '/'),
        _i7.RouteConfig(HomeViewRoute.name, path: '/home-view'),
        _i7.RouteConfig(CategoriesViewRoute.name, path: '/categories-view'),
        _i7.RouteConfig(SearchViewRoute.name, path: '/search-view'),
        _i7.RouteConfig(DetailsViewRoute.name, path: '/details-view'),
      ];
}

/// generated route for
/// [_i1.StartupView]
class StartupViewRoute extends _i7.PageRouteInfo<StartupViewArgs> {
  StartupViewRoute({_i8.Key? key})
      : super(
          StartupViewRoute.name,
          path: '/',
          args: StartupViewArgs(key: key),
        );

  static const String name = 'StartupView';
}

class StartupViewArgs {
  const StartupViewArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'StartupViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.HomeView]
class HomeViewRoute extends _i7.PageRouteInfo<HomeViewArgs> {
  HomeViewRoute({_i8.Key? key})
      : super(
          HomeViewRoute.name,
          path: '/home-view',
          args: HomeViewArgs(key: key),
        );

  static const String name = 'HomeView';
}

class HomeViewArgs {
  const HomeViewArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'HomeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.CategoriesView]
class CategoriesViewRoute extends _i7.PageRouteInfo<CategoriesViewArgs> {
  CategoriesViewRoute({_i8.Key? key, String? selectedCategory})
      : super(
          CategoriesViewRoute.name,
          path: '/categories-view',
          args:
              CategoriesViewArgs(key: key, selectedCategory: selectedCategory),
        );

  static const String name = 'CategoriesView';
}

class CategoriesViewArgs {
  const CategoriesViewArgs({this.key, this.selectedCategory});

  final _i8.Key? key;

  final String? selectedCategory;

  @override
  String toString() {
    return 'CategoriesViewArgs{key: $key, selectedCategory: $selectedCategory}';
  }
}

/// generated route for
/// [_i4.SearchView]
class SearchViewRoute extends _i7.PageRouteInfo<SearchViewArgs> {
  SearchViewRoute({_i8.Key? key})
      : super(
          SearchViewRoute.name,
          path: '/search-view',
          args: SearchViewArgs(key: key),
        );

  static const String name = 'SearchView';
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.DetailsView]
class DetailsViewRoute extends _i7.PageRouteInfo<DetailsViewArgs> {
  DetailsViewRoute({_i8.Key? key})
      : super(
          DetailsViewRoute.name,
          path: '/details-view',
          args: DetailsViewArgs(key: key),
        );

  static const String name = 'DetailsView';
}

class DetailsViewArgs {
  const DetailsViewArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'DetailsViewArgs{key: $key}';
  }
}

extension RouterStateExtension on _i6.RouterService {
  Future<dynamic> navigateToStartupView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToHomeView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(HomeViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToCategoriesView({
    _i8.Key? key,
    String? selectedCategory,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(
      CategoriesViewRoute(key: key, selectedCategory: selectedCategory),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToSearchView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(SearchViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToDetailsView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(DetailsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStartupView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithHomeView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(HomeViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithCategoriesView({
    _i8.Key? key,
    String? selectedCategory,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(
      CategoriesViewRoute(key: key, selectedCategory: selectedCategory),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithSearchView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(SearchViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithDetailsView({
    _i8.Key? key,
    void Function(_i7.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(DetailsViewRoute(key: key), onFailure: onFailure);
  }
}
