import 'dart:convert';
import 'dart:io';

/// HTTP client for the HyperDeck Control REST API.
///
/// Use [request] for every documented endpoint; it supports arbitrary paths,
/// HTTP verbs and JSON request bodies, including device-specific additions.
class HyperDeckRestClient {
  HyperDeckRestClient(this.baseUri, {HttpClient? httpClient})
      : _http = httpClient ?? HttpClient();
  final Uri baseUri;
  final HttpClient _http;

  Future<HyperDeckRestResponse> request(String method, String path,
      {Object? body, Map<String, String>? headers}) async {
    final uri =
        baseUri.resolve(path.startsWith('/') ? path.substring(1) : path);
    final request = await _http.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    headers?.forEach(request.headers.set);
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
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
        HyperDeckRestResponse(response.statusCode, value, response.headers);
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw HyperDeckRestException(result);
    return result;
  }

  Future<HyperDeckRestResponse> get(String path) => request('GET', path);
  Future<HyperDeckRestResponse> put(String path, [Object? body]) =>
      request('PUT', path, body: body);
  Future<HyperDeckRestResponse> post(String path, [Object? body]) =>
      request('POST', path, body: body);
  Future<HyperDeckRestResponse> delete(String path) => request('DELETE', path);
  Future<void> close({bool force = false}) async => _http.close(force: force);

  String _segment(String value) => Uri.encodeComponent(value);

  // Transport
  Future<HyperDeckRestResponse> transport() => get('/transports/0');
  Future<HyperDeckRestResponse> setTransportMode(String mode) =>
      put('/transports/0', {'mode': mode});
  Future<HyperDeckRestResponse> play() => post('/transports/0/play');
  Future<HyperDeckRestResponse> stop() => post('/transports/0/stop');
  Future<HyperDeckRestResponse> record([String? clipName]) => post(
      '/transports/0/record', clipName == null ? null : {'clipName': clipName});
  Future<HyperDeckRestResponse> setPlayback(Map<String, Object?> value) =>
      put('/transports/0/playback', value);
  Future<HyperDeckRestResponse> system() => get('/system');
  Future<HyperDeckRestResponse> clips() => get('/clips');
  Future<HyperDeckRestResponse> timeline() => get('/timelines/0');

  Future<HyperDeckRestResponse> isStopped() => get('/transports/0/stop');
  Future<HyperDeckRestResponse> stopDeprecated() => put('/transports/0/stop');
  Future<HyperDeckRestResponse> isPlaying() => get('/transports/0/play');
  Future<HyperDeckRestResponse> playDeprecated() => put('/transports/0/play');
  Future<HyperDeckRestResponse> playback() => get('/transports/0/playback');
  Future<HyperDeckRestResponse> recording() => get('/transports/0/record');
  Future<HyperDeckRestResponse> setRecording(bool recording,
          {String? clipName}) =>
      put('/transports/0/record', {
        'recording': recording,
        if (clipName != null) 'clipName': clipName,
      });
  Future<HyperDeckRestResponse> clipIndex() => get('/transports/0/clipIndex');
  Future<HyperDeckRestResponse> timecode() => get('/transports/0/timecode');
  Future<HyperDeckRestResponse> timecodeSource() =>
      get('/transports/0/timecode/source');
  Future<HyperDeckRestResponse> recordCache() =>
      get('/transports/0/recordCache');
  Future<HyperDeckRestResponse> isRecordCacheEnabled() =>
      get('/transports/0/recordCache/enabled');
  Future<HyperDeckRestResponse> setRecordCacheEnabled(bool enabled) =>
      put('/transports/0/recordCache/enabled', {'enabled': enabled});
  Future<HyperDeckRestResponse> recordSpillOrder() =>
      get('/transports/0/record/spillOrder');
  Future<HyperDeckRestResponse> spillRecordingToNewFile() =>
      post('/transports/0/record/spillToNewFile');
  Future<HyperDeckRestResponse> spillRecordingToNextDevice() =>
      post('/transports/0/record/spillToNextDevice');
  Future<HyperDeckRestResponse> inputVideoFormat() =>
      get('/transports/0/inputVideoFormat');
  Future<HyperDeckRestResponse> supportedInputVideoSources() =>
      get('/transports/0/supportedInputVideoSources');
  Future<HyperDeckRestResponse> inputVideoSource() =>
      get('/transports/0/inputVideoSource');
  Future<HyperDeckRestResponse> setInputVideoSource(String source) =>
      put('/transports/0/inputVideoSource', {'source': source});
  Future<HyperDeckRestResponse> currentClip() => get('/transports/0/clip');
  Future<HyperDeckRestResponse> recordFilenameConfiguration() =>
      get('/transports/0/record/filenameConfiguration');
  Future<HyperDeckRestResponse> setRecordFilenameConfiguration(
          Map<String, Object?> configuration) =>
      put('/transports/0/record/filenameConfiguration', configuration);
  Future<HyperDeckRestResponse> recordTrigger() =>
      get('/transports/0/record/trigger');
  Future<HyperDeckRestResponse> setRecordTrigger(String trigger) =>
      put('/transports/0/record/trigger', {'trigger': trigger});

  // System
  Future<HyperDeckRestResponse> product() => get('/system/product');
  Future<HyperDeckRestResponse> supportedCodecFormats() =>
      get('/system/supportedCodecFormats');
  Future<HyperDeckRestResponse> codecFormat() => get('/system/codecFormat');
  Future<HyperDeckRestResponse> setCodecFormat(Map<String, Object?> format) =>
      put('/system/codecFormat', format);
  Future<HyperDeckRestResponse> videoFormat() => get('/system/videoFormat');
  Future<HyperDeckRestResponse> setVideoFormat(Map<String, Object?> format) =>
      put('/system/videoFormat', format);
  Future<HyperDeckRestResponse> supportedVideoFormats() =>
      get('/system/supportedVideoFormats');
  Future<HyperDeckRestResponse> reboot() => post('/system/reboot');
  Future<HyperDeckRestResponse> uptime() => get('/system/uptime');
  Future<HyperDeckRestResponse> identify(bool enabled) =>
      put('/system/identify', {'enabled': enabled});

  // Media and NAS
  Future<HyperDeckRestResponse> workingSet() => get('/media/workingset');
  Future<HyperDeckRestResponse> activeMedia() => get('/media/active');
  Future<HyperDeckRestResponse> setActiveMedia(int workingsetIndex) =>
      put('/media/active', {'workingsetIndex': workingsetIndex});
  Future<HyperDeckRestResponse> formatSupportedFilesystems() =>
      get('/media/devices/doformatSupportedFilesystems');
  Future<HyperDeckRestResponse> mediaDevice(String deviceName) =>
      get('/media/devices/${_segment(deviceName)}');
  Future<HyperDeckRestResponse> prepareFormat(String deviceName) =>
      get('/media/devices/${_segment(deviceName)}/doformat');
  Future<HyperDeckRestResponse> formatMediaDevice(String deviceName,
          {required String key, required String filesystem, String? volume}) =>
      put('/media/devices/${_segment(deviceName)}/doformat', {
        'key': key,
        'filesystem': filesystem,
        if (volume != null) 'volume': volume,
      });
  Future<HyperDeckRestResponse> externalMedia() => get('/media/external');
  Future<HyperDeckRestResponse> selectedExternalMedia() =>
      get('/media/external/selected');
  Future<HyperDeckRestResponse> selectExternalMedia(String deviceName) =>
      put('/media/external/selected', {
        'selected': {'deviceName': deviceName}
      });
  Future<HyperDeckRestResponse> discoveredNasHosts() =>
      get('/media/nas/discovered');
  Future<HyperDeckRestResponse> nasBookmarks() => get('/media/nas/bookmarks');
  Future<HyperDeckRestResponse> addNasBookmark(String url,
          {String? username, String? password}) =>
      post('/media/nas/bookmarks', {
        'url': url,
        if (username != null) 'username': username,
        if (password != null) 'password': password,
      });
  Future<HyperDeckRestResponse> nasBookmark(String url) =>
      get('/media/nas/bookmarks/${_segment(url)}');
  Future<HyperDeckRestResponse> updateNasBookmark(String url,
          {String? username, String? password}) =>
      put('/media/nas/bookmarks/${_segment(url)}', {
        if (username != null) 'username': username,
        if (password != null) 'password': password,
      });
  Future<HyperDeckRestResponse> removeNasBookmark(String url) =>
      delete('/media/nas/bookmarks/${_segment(url)}');
  Future<HyperDeckRestResponse> selectedNasBookmark() =>
      get('/media/nas/selected');
  Future<HyperDeckRestResponse> selectNasBookmark(String? url) =>
      put('/media/nas/selected', {
        'selected': url == null ? null : {'url': url}
      });

  // Timeline and clips
  Future<HyperDeckRestResponse> clearTimelineDeprecated() =>
      delete('/timelines/0');
  Future<HyperDeckRestResponse> addTimelineClips(Object clips,
          {int? insertBefore}) =>
      post('/timelines/0', {
        'clips': clips,
        if (insertBefore != null) 'insertBefore': insertBefore,
      });
  Future<HyperDeckRestResponse> appendTimelineClips(Object clips) =>
      post('/timelines/0/add', {'clips': clips});
  Future<HyperDeckRestResponse> clearTimeline() => post('/timelines/0/clear');
  Future<HyperDeckRestResponse> removeTimelineClip(int timelineClipIndex) =>
      delete('/timelines/0/clips/$timelineClipIndex');
  Future<HyperDeckRestResponse> timelinePlayRange() =>
      get('/timelines/0/playRange');
  Future<HyperDeckRestResponse> setTimelinePlayRange(
          Map<String, Object?>? playRange) =>
      put('/timelines/0/playRange', {'playRange': playRange});
  Future<HyperDeckRestResponse> clearTimelinePlayRange() =>
      post('/timelines/0/playRange/clear');
  Future<HyperDeckRestResponse> timelineVideoFormat() =>
      get('/timelines/0/videoFormat');
  Future<HyperDeckRestResponse> setTimelineVideoFormat(
          Map<String, Object?> format) =>
      put('/timelines/0/videoFormat', format);
  Future<HyperDeckRestResponse> defaultTimelineVideoFormat() =>
      get('/timelines/0/defaultVideoFormat');
  Future<HyperDeckRestResponse> setDefaultTimelineVideoFormat(
          Map<String, Object?> format) =>
      put('/timelines/0/defaultVideoFormat', format);
  Future<HyperDeckRestResponse> rebuildTimeline() =>
      post('/timelines/0/rebuild');
  Future<HyperDeckRestResponse> clipsOnDevice(String deviceName) =>
      get('/clips/devices/${_segment(deviceName)}');

  // Audio
  Future<HyperDeckRestResponse> supportedRecordAudioFormats() =>
      get('/audio/supportedRecordFormats');
  Future<HyperDeckRestResponse> recordAudioFormat() =>
      get('/audio/recordFormat');
  Future<HyperDeckRestResponse> setRecordAudioFormat(
          {required String codec, required int numChannels}) =>
      put('/audio/recordFormat', {'codec': codec, 'numChannels': numChannels});

  // Monitoring
  Future<HyperDeckRestResponse> displays() => get('/monitoring/display');
  Future<HyperDeckRestResponse> cleanFeed(String displayName) =>
      get('/monitoring/${_segment(displayName)}/cleanFeed');
  Future<HyperDeckRestResponse> setCleanFeed(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/cleanFeed',
          {'enabled': enabled});
  Future<HyperDeckRestResponse> displayLut(String displayName) =>
      get('/monitoring/${_segment(displayName)}/displayLUT');
  Future<HyperDeckRestResponse> setDisplayLut(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/displayLUT',
          {'enabled': enabled});
  Future<HyperDeckRestResponse> displayZebra(String displayName) =>
      get('/monitoring/${_segment(displayName)}/zebra');
  Future<HyperDeckRestResponse> setDisplayZebra(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/zebra', {'enabled': enabled});
  Future<HyperDeckRestResponse> displayFocusAssist(String displayName) =>
      get('/monitoring/${_segment(displayName)}/focusAssist');
  Future<HyperDeckRestResponse> setDisplayFocusAssist(
          String displayName, Map<String, Object?> settings) =>
      put('/monitoring/${_segment(displayName)}/focusAssist', settings);
  Future<HyperDeckRestResponse> focusAssist() => get('/monitoring/focusAssist');
  Future<HyperDeckRestResponse> setFocusAssist(Map<String, Object?> settings) =>
      put('/monitoring/focusAssist', settings);
  Future<HyperDeckRestResponse> frameGuide(String displayName) =>
      get('/monitoring/${_segment(displayName)}/frameGuide');
  Future<HyperDeckRestResponse> setFrameGuide(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/frameGuide',
          {'enabled': enabled});
  Future<HyperDeckRestResponse> frameGuideRatio() =>
      get('/monitoring/frameGuideRatio');
  Future<HyperDeckRestResponse> setFrameGuideRatio(String ratio) =>
      put('/monitoring/frameGuideRatio', {'ratio': ratio});
  Future<HyperDeckRestResponse> frameGuideRatioPresets() =>
      get('/monitoring/frameGuideRatio/presets');
  Future<HyperDeckRestResponse> displayFrameGrids(String displayName) =>
      get('/monitoring/${_segment(displayName)}/frameGrids');
  Future<HyperDeckRestResponse> setDisplayFrameGrids(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/frameGrids',
          {'enabled': enabled});
  Future<HyperDeckRestResponse> frameGrids() => get('/monitoring/frameGrids');
  Future<HyperDeckRestResponse> setFrameGrids(List<String> grids) =>
      put('/monitoring/frameGrids', {'frameGrids': grids});
  Future<HyperDeckRestResponse> falseColor(String displayName) =>
      get('/monitoring/${_segment(displayName)}/falseColor');
  Future<HyperDeckRestResponse> setFalseColor(
          String displayName, bool enabled) =>
      put('/monitoring/${_segment(displayName)}/falseColor',
          {'enabled': enabled});
  Future<HyperDeckRestResponse> zebra() => get('/monitoring/zebra');
  Future<HyperDeckRestResponse> setZebraLevel(int level) =>
      put('/monitoring/zebra', {
        'highlight': {'level': level}
      });
  Future<HyperDeckRestResponse> supportedZebraLevels() =>
      get('/monitoring/supportedZebraLevels');

  // REST notification discovery and WebSocket connection.
  Future<HyperDeckRestResponse> eventList() => get('/event/list');
  Future<HyperDeckEventSocket> connectEvents({String path = '/event'}) async =>
      HyperDeckEventSocket.connect(baseUri, path: path);
}

class HyperDeckRestResponse {
  HyperDeckRestResponse(this.statusCode, this.body, this.headers);
  final int statusCode;
  final Object? body;
  final HttpHeaders headers;
}

class HyperDeckRestException implements Exception {
  HyperDeckRestException(this.response);
  final HyperDeckRestResponse response;
  @override
  String toString() =>
      'HyperDeck REST request failed (${response.statusCode}): ${response.body}';
}

/// Client for the REST API notification WebSocket. The device replies to
/// subscribe, unsubscribe, listSubscriptions and listProperties commands on
/// [messages], and emits propertyValueChanged events on the same stream.
class HyperDeckEventSocket {
  HyperDeckEventSocket._(this._socket);
  final WebSocket _socket;

  static Future<HyperDeckEventSocket> connect(Uri baseUri,
      {String path = '/event'}) async {
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final resolved = baseUri.resolve(
      path.startsWith('/') ? path.substring(1) : path,
    );
    final uri = resolved.replace(scheme: scheme, query: null, fragment: null);
    return HyperDeckEventSocket._(await WebSocket.connect(uri.toString()));
  }

  Stream<Object?> get messages => _socket.map((event) {
        if (event is String) return jsonDecode(event);
        return event;
      });
  void send(String action,
          {List<String>? properties, Object? values, int? id}) =>
      _socket.add(jsonEncode({
        'data': {
          'action': action,
          if (properties != null) 'properties': properties,
          if (values != null) 'values': values,
        },
        if (id != null) 'id': id,
      }));
  void subscribe(List<String> properties, {int? id}) =>
      send('subscribe', properties: properties, id: id);
  void unsubscribe(List<String> properties, {int? id}) =>
      send('unsubscribe', properties: properties, id: id);
  void listSubscriptions({int? id}) => send('listSubscriptions', id: id);
  void listProperties({int? id}) => send('listProperties', id: id);
  Future<void> close([int? code, String? reason]) =>
      _socket.close(code, reason);
}