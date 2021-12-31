import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ignore: implementation_imports
import 'package:flutter/src/painting/binding.dart';

// ignore: implementation_imports
import 'package:flutter/src/painting/debug.dart';

// ignore: implementation_imports
import 'package:flutter/src/painting/image_provider.dart' as image_provider;

// ignore: implementation_imports
import 'package:flutter/src/painting/image_stream.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'network.dart';

/// The package:ditiezu implementation of [image_provider.NetworkImage].
@immutable
class ExtendedNetworkImage
    extends image_provider.ImageProvider<image_provider.NetworkImage>
    implements image_provider.NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const ExtendedNetworkImage(this.url,
      {this.scale = 1.0, required this.headers});

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  @override
  Future<ExtendedNetworkImage> obtainKey(
      image_provider.ImageConfiguration configuration) {
    return SynchronousFuture<ExtendedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(
      image_provider.NetworkImage key, image_provider.DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key as ExtendedNetworkImage, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<image_provider.ImageProvider>(
              'Image provider', this),
          DiagnosticsProperty<image_provider.NetworkImage>('Image key', key),
        ];
      },
    );
  }

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) {
        client = debugNetworkImageHttpClientProvider!();
      }
      return true;
    }());
    // client.findProxy = (uri) {
    //   return "PROXY 192.168.50.201:8888";
    // };
    return client;
  }

  Future<ui.Codec> _loadAsync(
    ExtendedNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    image_provider.DecoderCallback decode,
  ) async {
    try {
      assert(key == this);

      final Uri resolved = Uri.base.resolve(key.url);

      var path =
          join((await getApplicationDocumentsDirectory()).path, ".cookies");
      var cookieJar = PersistCookieJar(storage: FileStorage(path));
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      request.cookies.addAll(await cookieJar.loadForRequest(request.uri));

      headers.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      var response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        if (!url.contains("avatar")) {
          throw image_provider.NetworkImageLoadException(
              statusCode: response.statusCode, uri: resolved);
        }
      }
      if (response.redirects.isNotEmpty) {
        Uri uri = response.redirects.first.location;
        var useIP = false;
        if (uri.host.contains("ditiezu.com")) {
          useIP = true;
          uri = uri.replace(
              host: hostIP
                  .substring(0, hostIP.length - 1)
                  .replaceFirst("http://", ""));
        }
        final String method = response.redirects.first.method;
        final HttpClientRequest redirectRequest =
            await _httpClient.openUrl(method, uri);
        redirectRequest.cookies
            .addAll(await cookieJar.loadForRequest(redirectRequest.uri));
        if (useIP) {
          headers.forEach((String name, String value) {
            redirectRequest.headers.add(name, value);
          });
        }
        response = await redirectRequest.close();
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      cookieJar.saveFromResponse(resolved, response.cookies);
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      return decode(bytes);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance?.imageCache?.evict(key);
      });

      ByteData? data;
      // Hot reload/restart could change whether an asset bundle or key in a
      // bundle are available, or if it is a network backed bundle.
      try {
        data = await rootBundle.load("assets/images/noavatar_middle.png");
      } on FlutterError {
        PaintingBinding.instance!.imageCache!.evict(key);
        rethrow;
      }
      return decode(data.buffer.asUint8List());
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ExtendedNetworkImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ExtendedNetworkImage')}("$url", scale: $scale, headers: $headers)';
}
