/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'dart:async';
import 'dart:io';

import 'package:Medito/network/auth.dart';
import 'package:Medito/network/session_options/session_opts.dart';
import 'package:Medito/utils/shared_preferences_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

var downloadListener = ValueNotifier<double>(0);
var bgDownloadListener = ValueNotifier<double>(0);
int bgTotal = 1, bgReceived = 0;

Future<dynamic> checkFileExists(AudioFile currentFile) async {
  if(kIsWeb) return null;
  var filePath = (await getFilePath(currentFile.id));
  var file = File(filePath);
  var exists = await file.exists();
  return exists;
}

Future<dynamic> checkBgSoundExists(String name) async {
  if(kIsWeb) return null;
  var filePath = (await getFilePath(name));
  var file = File(filePath);
  var exists = await file.exists();
  return exists;
}

Future<dynamic> downloadBGMusicFromURL(String? url, String? name) async {
  if(kIsWeb) return null;

  var path = (await getFilePath(name));
  var file = File(path);
  if (await file.exists()) return file.path;
  try {
    var request = await http.get(Uri.parse(url ?? ''),
        headers: {HttpHeaders.authorizationHeader: CONTENT_TOKEN});
    var bytes = request.bodyBytes;
    await file.writeAsBytes(bytes);
    await addBgSoundToOfflineSharedPrefs(name, file.path);
    return file.path;
  } catch (e) {
    print(e);
    return 'Connectivity lost';
  }
}

Future<String> getFilePath(String? mediaItemId) async {
  if(kIsWeb) return '';

  var dir = (await getApplicationSupportDirectory()).path;
  return '$dir/${mediaItemId?.replaceAll('/', '_').replaceAll(' ', '_')}.mp3';
}

Future<dynamic> getDownload(String filename) async {
  if(kIsWeb) return '';
  var path = (await getFilePath(filename));
  var file = File(path);
  if (await file.exists()) {
    return file.path;
  } else {
    return null;
  }
}
