import 'dart:html' as html;

import 'package:angular/angular.dart' show Injectable, Inject, Optional;

import 'location.dart' show Location;
import 'location_strategy.dart' show LocationStrategy, appBaseHref;
import 'platform_location.dart' show PlatformLocation;

/// `HashLocationStrategy` is a [LocationStrategy] used to configure the
/// [PlatformLocation] service to represent its state in the
/// [hash fragment](https://en.wikipedia.org/wiki/Uniform_Resource_Locator#Syntax)
/// of the browser's URL.
///
/// For instance, if you call `location.go('/foo')`, the browser's URL will become
/// `example.com#/foo`.
///
/// ### Example
///
/// ```
/// import 'package:angular/angular.dart';
/// import 'package:angular_router/angular_router.dart';
///
/// @Component(
///   // Should only be provided at the root.
///   providers: [
///     routerProvidersHash,
///   ],
/// )
/// class AppComponent {
///   AppComponent(Location location) {
///     location.go('/foo');
///   }
/// }
/// ```
@Injectable()
class HashLocationStrategy extends LocationStrategy {
  final PlatformLocation _platformLocation;
  final String _baseHref;

  HashLocationStrategy(
    this._platformLocation, [
    @Optional() @Inject(appBaseHref) String baseHref,
  ]) : _baseHref = baseHref ?? '';

  @override
  void onPopState(html.EventListener fn) {
    _platformLocation.onPopState(fn);
  }

  @override
  String getBaseHref() {
    return _baseHref;
  }

  @override
  String hash() {
    return _platformLocation.hash;
  }

  @override
  String path() {
    // the hash value is always prefixed with a `#`
    // and if it is empty then it will stay empty
    var path = _platformLocation.hash ?? '';
    // Dart will complain if a call to substring is
    // executed with a position value that extends the
    // length of string.
    return path.isEmpty ? path : path.substring(1);
  }

  @override
  String prepareExternalUrl(String internal) {
    var url = Location.joinWithSlash(_baseHref, internal);
    // It's convention that if the hash path is empty, we omit the `#`; however,
    // if the empty URL is pushed it won't replace any existing fragment. So
    // when the hash path is empty, we instead return the location's path and
    // query.
    return url.isEmpty
        ? '${_platformLocation.pathname}${_platformLocation.search}'
        : '#$url';
  }

  @override
  void pushState(dynamic state, String title, String path, String queryParams) {
    var url =
        prepareExternalUrl(path + Location.normalizeQueryParams(queryParams));
    _platformLocation.pushState(state, title, url);
  }

  @override
  void replaceState(
      dynamic state, String title, String path, String queryParams) {
    var url =
        prepareExternalUrl(path + Location.normalizeQueryParams(queryParams));
    _platformLocation.replaceState(state, title, url);
  }

  @override
  void forward() {
    _platformLocation.forward();
  }

  @override
  void back() {
    _platformLocation.back();
  }
}
