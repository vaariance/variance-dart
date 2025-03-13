library;

import 'dart:convert';
import 'package:build/build.dart';

/// A builder that converts .abi.json files into .m.dart files.
class AbiJsonBuilder implements Builder {
  /// Maps input files with the `.abi.json` extension to output files with the `.m.dart` extension.
  @override
  final buildExtensions = const {
    '.abi.json': ['.m.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process files under the modules directory if needed.
    // You can also filter this in your build.yaml.
    if (!buildStep.inputId.path.contains('/modules/')) {
      return;
    }

    // Read the contents of the input file.
    final inputId = buildStep.inputId;
    final withoutExtension =
        inputId.path.substring(0, inputId.path.length - '.abi.json'.length);
    final content = json.decode(await buildStep.readAsString(inputId));

    // For our purposes, we assume the ABI JSON content is valid.
    // If needed, you could parse it using jsonDecode(content) for further validation.

    // Derive a base name (without extensions) for the generated class.
    final fileName = withoutExtension.split('/').last;
    final className = '${fileName.split('_').map(_capitalize).join()}Contract';

    // Generate Dart code.
    final outputContent = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from ${inputId.path}

import 'package:web3dart/web3dart.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi ${fileName}_abi = ContractAbi.fromJson('${jsonEncode(content)}', '$fileName');

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class $className {
  final DeployedContract contract;

  $className(EthereumAddress address)
      : contract = DeployedContract(${fileName}_abi, address);
}
''';

    // Write the generated code to the corresponding .m.dart file.
    final outputId = AssetId(inputId.package, '$withoutExtension.m.dart');
    await buildStep.writeAsString(outputId, outputContent);
  }

  /// Helper to capitalize the first letter.
  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}

/// Factory for the builder.
Builder abiJsonBuilder(BuilderOptions options) => AbiJsonBuilder();
