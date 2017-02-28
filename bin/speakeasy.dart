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

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pub_server/shelf_pubserver.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:speakeasy/configuration.dart';
import 'package:speakeasy/repository.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

const String _configOption = 'config';

Future<Null> main(List<String> args) async {
  _setupLogger();

  // Parse the arguments
  final parser = new ArgParser()
    ..addOption(_configOption, defaultsTo: 'config.yml');

  final parsed = parser.parse(args);

  final configPath = parsed[_configOption] as String;

  // Attempt to read the file
  var config = await readConfiguration(configPath);

  // See if the config file is present
  if (config.isEmpty) {
    print('File not present');

    config = await writeDefaultConfiguration(configPath);
  }

  // Create the file repository based on the value of storage
  final fileRepository = new FileRepository(config['storage'] as String);

  // Create the proxies
  //
  // \TODO More than one :)
  final httpClient = new http.Client();
  final pubRepository = new HttpProxyRepository(
      httpClient,
      Uri.parse(
        config['proxies']['dartlang']['url'] as String
      ),);

  final cowRepository = new CopyAndWriteRepository(fileRepository, pubRepository);

  // Just start up the server for now
  final server = new ShelfPubServer(cowRepository);

  // Get the address based on the IP address
  final interfaces = await NetworkInterface.list();
  final address = interfaces[0].addresses.first.address;

  final port = 8080;

  shelf_io.serve(server.requestHandler, address, port);

  _printClientUsage(address, port, false);
}

void _setupLogger() {
  Logger.root.onRecord.listen((LogRecord record) {
    final head = '${record.time} ${record.level} ${record.loggerName}';
    final tail = record.stackTrace != null ? '\n${record.stackTrace}' : '';
    print('$head ${record.message} $tail');
  });
}

void _printClientUsage(String address, int port, bool isSecure) {
  final scheme = isSecure ? 'https' : 'http';
  final hostedUrl = '$scheme://$address:$port';

  print(
      '################################################################################');
  print(
      'The pub command uses environment variables to specify the registry to use.');
  print(
      'If you want to setup pub to work with this registry run the following commands:\n');
  print('POSIX OS');
  print('\$ export PUB_HOSTED_URL=$hostedUrl\n');
  print('WINDOWS');
  print('\$ SET PUB_HOSTED_URL=$hostedUrl\n');
  print(
      'To prevent pub publish from unintentially publishing to the pub.dartlang.org');
  print('registry include the following in the package pubspec.yml\n');
  print('publish_to: $hostedUrl');
  print(
      '################################################################################');
}
