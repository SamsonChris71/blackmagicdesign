import 'dart:convert';
import 'dart:io';

import 'web_presenter_xml.dart';

/// REST client for every endpoint in the Streaming Encoder Control REST API.
class WebPresenterRestClient {
  WebPresenterRestClient(Uri deviceUri, {HttpClient? httpClient})
      : baseUri = _apiUri(deviceUri),
        _http = httpClient ?? HttpClient();
  final Uri baseUri;
  final HttpClient _http;

  static Uri _apiUri(Uri uri) {
    final path = uri.path.isEmpty ? '/' : uri.path;
    final normalizedPath = path.endsWith('/') ? path : '$path/';
    if (normalizedPath.endsWith('/control/api/v1/')) {
      return uri.replace(path: normalizedPath, query: null, fragment: null);
    }
    final basePath = normalizedPath == '/' ? '' : normalizedPath.substring(1);
    return uri.replace(
      path: '/${basePath}control/api/v1/',
      query: null,
      fragment: null,
    );
  }

  String _segment(String value) => Uri.encodeComponent(value);

  Future<WebPresenterRestResponse> request(String method, String path,
      {Object? body, String? contentType, Map<String, String>? headers}) async {
    final request = await _http.openUrl(
      method,
      baseUri.resolve(path.startsWith('/') ? path.substring(1) : path),
    );
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    headers?.forEach(request.headers.set);
    if (body != null) {
      if (body is String) {
        request.headers.contentType =
            ContentType.parse(contentType ?? 'application/xml; charset=utf-8');
        request.write(body);
      } else {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
    }
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    Object? value;
    if (text.isNotEmpty) {
      try {
        value = jsonDecode(text);
      } on FormatException {
        value = text;
      }
    }
    final result =
        WebPresenterRestResponse(response.statusCode, value, response.headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WebPresenterRestException(result);
    }
    return result;
  }

  Future<WebPresenterRestResponse> get(String path) => request('GET', path);
  Future<WebPresenterRestResponse> put(String path, [Object? body]) =>
      request('PUT', path, body: body);
  Future<WebPresenterRestResponse> post(String path, [Object? body]) =>
      request('POST', path, body: body);
  Future<WebPresenterRestResponse> delete(String path) =>
      request('DELETE', path);
  Future<void> close({bool force = false}) async => _http.close(force: force);

  Future<WebPresenterRestResponse> eventList() => get('/event/list');
  Future<WebPresenterRestResponse> livestream() => get('/livestreams/0');
  Future<WebPresenterRestResponse> isStreamActive() =>
      get('/livestreams/0/start');
  Future<WebPresenterRestResponse> startStream() => put('/livestreams/0/start');
  Future<WebPresenterRestResponse> isStreamStopped() =>
      get('/livestreams/0/stop');
  Future<WebPresenterRestResponse> stopStream() => put('/livestreams/0/stop');
  Future<WebPresenterRestResponse> activePlatform() =>
      get('/livestreams/0/activePlatform');
  Future<WebPresenterRestResponse> setActivePlatform(
          Map<String, Object?> platform) =>
      put('/livestreams/0/activePlatform', platform);
  Future<WebPresenterRestResponse> platforms() => get('/livestreams/platforms');
  Future<WebPresenterRestResponse> platform(String name) =>
      get('/livestreams/platforms/${_segment(name)}');
  Future<WebPresenterRestResponse> customPlatforms() =>
      get('/livestreams/customPlatforms');
  Future<WebPresenterRestResponse> removeAllCustomPlatforms() =>
      delete('/livestreams/customPlatforms');
  Future<WebPresenterRestResponse> customPlatform(String filename) =>
      get('/livestreams/customPlatforms/${_segment(filename)}');
  Future<WebPresenterRestResponse> uploadCustomPlatform(
    String filename,
    String xml, {
    bool compact = true,
  }) =>
      request(
        'PUT',
        '/livestreams/customPlatforms/${_segment(filename)}',
        body: compact ? StreamingXmlDocument.compact(xml) : xml,
      );
  Future<WebPresenterRestResponse> removeCustomPlatform(String filename) =>
      delete('/livestreams/customPlatforms/${_segment(filename)}');
  Future<WebPresenterRestResponse> monitorOutputAudioSources() =>
      get('/monitorOutput/audioSources');
  Future<WebPresenterRestResponse> activeMonitorOutputAudioSource() =>
      get('/monitorOutput/audioSources/active');
  Future<WebPresenterRestResponse> setMonitorOutputAudioSource(String source) =>
      put('/monitorOutput/audioSources/active', {'audioSource': source});
  Future<WebPresenterRestResponse> system() => get('/system');
  Future<WebPresenterRestResponse> product() => get('/system/product');
  Future<WebPresenterRestResponse> videoFormat() => get('/system/videoFormat');
  Future<WebPresenterRestResponse> setVideoFormat(
          Map<String, Object?> format) =>
      put('/system/videoFormat', format);
  Future<WebPresenterRestResponse> supportedVideoFormats() =>
      get('/system/supportedVideoFormats');

  /// Connects to the documented notification WebSocket.
  Future<WebPresenterEventSocket> connectEvents({String path = '/event'}) =>
      WebPresenterEventSocket.connect(baseUri, path: path);
}

class WebPresenterRestResponse {
  WebPresenterRestResponse(this.statusCode, this.body, this.headers);
  final int statusCode;
  final Object? body;
  final HttpHeaders headers;
}

class WebPresenterRestException implements Exception {
  WebPresenterRestException(this.response);
  final WebPresenterRestResponse response;
  @override
  String toString() =>
      'Web Presenter REST request failed (${response.statusCode}): '
      '${response.body}';
}

/// Client for the Streaming Encoder REST notification WebSocket.
class WebPresenterEventSocket {
  WebPresenterEventSocket._(this._socket);

  final WebSocket _socket;

  static Future<WebPresenterEventSocket> connect(Uri baseUri,
      {String path = '/event'}) async {
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final resolved = baseUri.resolve(
      path.startsWith('/') ? path.substring(1) : path,
    );
    final uri = resolved.replace(scheme: scheme, query: null, fragment: null);
    return WebPresenterEventSocket._(await WebSocket.connect(uri.toString()));
  }

  Stream<Object?> get messages => _socket.map((event) {
        if (event is String) return jsonDecode(event);
        return event;
      });

  void send(String action,
      {List<String>? properties, Object? values, int? id}) {
    _socket.add(jsonEncode({
      'data': {
        'action': action,
        if (properties != null) 'properties': properties,
        if (values != null) 'values': values,
      },
      if (id != null) 'id': id,
    }));
  }

  void subscribe(List<String> properties, {int? id}) =>
      send('subscribe', properties: properties, id: id);
  void unsubscribe(List<String> properties, {int? id}) =>
      send('unsubscribe', properties: properties, id: id);
  void listSubscriptions({int? id}) => send('listSubscriptions', id: id);
  void listProperties({int? id}) => send('listProperties', id: id);
  Future<void> close([int? code, String? reason]) =>
      _socket.close(code, reason);
}
