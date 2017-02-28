// Copyright (c) 2015, the Speakeasy Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

//---------------------------------------------------------------------
// Standard libraries
//---------------------------------------------------------------------

import 'dart:async';
import 'dart:io';

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:resource/resource.dart';
import 'package:yaml/yaml.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Reads the configuration file from the [path].
///
/// If the file could not be read or then an empty map will be returned.
Future<Map> readConfiguration(String path) async {
  final file = new File(path);

  // See if the file exists
  if (!await file.exists()) {
    return {};
  }

  // Parse the file and return its contents
  final contents = await file.readAsString();
  return loadYaml(contents) as Map;
}

/// Writes the default configuration to the [path].
///
/// The default configuration will be returned by the function.
Future<Map> writeDefaultConfiguration(String path) async {
  // Get the contents of the resource
  final resource = new Resource('package:speakeasy/src/configuration/default.yml');
  final contents = await resource.readAsString();

  // Write the contents to the path
  final file = new File(path);
  await file.writeAsString(contents);

  // Parse the file and return it
  return loadYaml(contents) as Map;
}
