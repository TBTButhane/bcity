// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner/src/build_plan/builder_factories.dart' as _i1;
import 'package:build_modules/builders.dart' as _i2;
import 'package:build_web_compilers/builders.dart' as _i3;
import 'package:jaspr_builder/builder.dart' as _i4;
import 'package:source_gen/builder.dart' as _i5;
import 'dart:io' as _i6;
import 'package:build_runner/src/bootstrap/processes.dart' as _i7;

final _builderFactories = _i1.BuilderFactories(
  {
    'build_modules:module_library': [_i2.moduleLibraryBuilder],
    'build_web_compilers:dart2js_modules': [
      _i3.dart2jsMetaModuleBuilder,
      _i3.dart2jsMetaModuleCleanBuilder,
      _i3.dart2jsModuleBuilder,
    ],
    'build_web_compilers:dart2wasm_modules': [
      _i3.dart2wasmMetaModuleBuilder,
      _i3.dart2wasmMetaModuleCleanBuilder,
      _i3.dart2wasmModuleBuilder,
    ],
    'build_web_compilers:ddc': [
      _i3.ddcKernelBuilder,
      _i3.ddcBuilder,
    ],
    'build_web_compilers:ddc_modules': [
      _i3.ddcMetaModuleBuilder,
      _i3.ddcMetaModuleCleanBuilder,
      _i3.ddcModuleBuilder,
    ],
    'build_web_compilers:entrypoint': [_i3.webEntrypointBuilder],
    'build_web_compilers:entrypoint_marker': [_i3.webEntrypointMarkerBuilder],
    'build_web_compilers:sdk_js': [
      _i3.sdkJsCompile,
      _i3.sdkJsCopyRequirejs,
    ],
    'jaspr_builder:client_entrypoint': [_i4.buildClientEntrypoint],
    'jaspr_builder:client_module': [_i4.buildClientModule],
    'jaspr_builder:client_options': [_i4.buildClientOptions],
    'jaspr_builder:clients_bundle': [_i4.buildClientsBundle],
    'jaspr_builder:codec_bundle': [_i4.buildCodecBundle],
    'jaspr_builder:codec_module': [_i4.buildCodecModule],
    'jaspr_builder:import_output': [_i4.buildImportsOutput],
    'jaspr_builder:imports_module': [_i4.buildImportsModule],
    'jaspr_builder:server_options': [_i4.buildServerOptions],
    'jaspr_builder:stub': [_i4.buildPlatformStubs],
    'jaspr_builder:styles_bundle': [_i4.buildStylesBundle],
    'jaspr_builder:styles_module': [_i4.buildStylesModule],
    'jaspr_builder:sync_mixins_module': [_i4.buildSyncMixins],
    'source_gen:combining_builder': [_i5.combiningBuilder],
  },
  postProcessBuilderFactories: {
    'build_modules:module_cleanup': _i2.moduleCleanup,
    'build_web_compilers:dart2js_archive_extractor':
        _i3.dart2jsArchiveExtractor,
    'build_web_compilers:dart_source_cleanup': _i3.dartSourceCleanup,
    'source_gen:part_cleanup': _i5.partCleanup,
  },
);
void main(List<String> args) async {
  _i6.exitCode = await _i7.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
