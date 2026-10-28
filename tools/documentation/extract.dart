// Run with the Flutter tools package configuration (analyzer is supplied by Flutter).
import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

String signature(AstNode node) {
  if (node is MethodDeclaration) {
    return '${node.isStatic ? 'static ' : ''}${node.returnType ?? 'dynamic'} ${node.isGetter ? 'get ' : ''}${node.name}${node.typeParameters ?? ''}${node.parameters ?? ''}';
  }
  if (node is ConstructorDeclaration) {
    // Dart 3.13 private field formals have public parameter names.
    return '${node.constKeyword != null ? 'const ' : ''}${node.factoryKeyword != null ? 'factory ' : ''}${node.returnType}${node.name == null ? '' : '.${node.name}'}${node.parameters}'.replaceAll('this._', 'this.');
  }
  if (node is FunctionDeclaration) {
    return '${node.returnType ?? 'dynamic'} ${node.name}${node.functionExpression.typeParameters ?? ''}${node.functionExpression.parameters ?? ''}';
  }
  return node.toSource();
}

void main(List<String> args) {
  final result = <Object>[];
  for (final file in Directory('flutter/lib/src').listSync().whereType<File>().where((f) => f.path.endsWith('.dart'))) {
    if (['calendar.dart', 'data.dart', 'date_format.dart', 'file_drop.dart', 'multipart.dart'].any(file.path.endsWith)) continue;
    final source = file.readAsStringSync();
    final unit = parseString(content: source).unit;
    for (final node in unit.declarations) {
      final name = switch (node) {
        ClassDeclaration n => n.name.lexeme,
        MixinDeclaration n => n.name.lexeme,
        EnumDeclaration n => n.name.lexeme,
        GenericTypeAlias n => n.name.lexeme,
        FunctionDeclaration n => n.name.lexeme,
        _ => '',
      };
      if (name.isEmpty || name.startsWith('_')) continue;
      if (['configureFileDrops', 'updateFileDropTargets', 'browserFileUploadBody'].contains(name)) continue;
      final members = switch (node) {
        ClassDeclaration n => n.members,
        MixinDeclaration n => n.members,
        _ => <ClassMember>[],
      };
      final entries = <Object>[];
      for (final member in members) {
        if (member is FieldDeclaration) {
          for (final variable in member.fields.variables) {
            if (variable.name.lexeme.startsWith('_')) continue;
            final fieldType = member.fields.type?.toSource() ?? switch (variable.name.lexeme) {
              'light' || 'dark' => 'TxThemeData',
              'delegates' => 'List<LocalizationsDelegate<dynamic>>',
              'supportedLocales' => 'List<Locale>',
              _ => 'inferred',
            };
            entries.add({'name': variable.name.lexeme, 'kind': 'field', 'signature': '${member.isStatic ? 'static ' : ''}${member.fields.keyword?.lexeme ?? ''} $fieldType ${variable.name}${variable.initializer == null ? '' : ' = ${variable.initializer}'}', 'offset': member.offset, 'commentStart': member.documentationComment?.offset, 'commentEnd': member.documentationComment?.end, 'documented': member.documentationComment != null});
          }
        } else if (member is MethodDeclaration && !member.name.lexeme.startsWith('_')) {
          if (['build', 'createState', 'initState', 'didUpdateWidget'].contains(member.name.lexeme)) continue;
          entries.add({'name': member.name.lexeme, 'kind': 'method', 'signature': signature(member), 'offset': member.offset, 'commentStart': member.documentationComment?.offset, 'commentEnd': member.documentationComment?.end, 'documented': member.documentationComment != null});
        } else if (member is ConstructorDeclaration && !(member.name?.lexeme.startsWith('_') ?? false)) {
          final parameters = <Object>[];
          for (final parameter in member.parameters.parameters) {
            final bare = parameter is DefaultFormalParameter ? parameter.parameter : parameter;
            var parameterType = bare is SimpleFormalParameter ? '${bare.type ?? 'dynamic'}' : '';
            if (bare is FieldFormalParameter) {
              for (final field in members.whereType<FieldDeclaration>()) {
                if (field.fields.variables.any((v) => v.name.lexeme == bare.name.lexeme)) {
                  parameterType = '${bare.type ?? field.fields.type ?? 'dynamic'}';
                }
              }
            }
            if (bare is SuperFormalParameter) parameterType = switch (bare.name.lexeme) {
              'key' => 'Key?',
              'lat' || 'lng' => 'double',
              _ => 'dynamic',
            };
            parameters.add({'name': (bare.name?.lexeme ?? '').replaceFirst(RegExp(r'^_'), ''), 'type': parameterType, 'required': parameter.isRequired, 'default': parameter is DefaultFormalParameter ? parameter.defaultValue?.toSource() : null});
          }
          entries.add({'name': member.name == null ? name : '$name.${member.name}', 'kind': 'constructor', 'signature': signature(member), 'parameters': parameters, 'offset': member.offset, 'commentStart': member.documentationComment?.offset, 'commentEnd': member.documentationComment?.end, 'documented': member.documentationComment != null});
        }
      }
      result.add({'name': name, 'file': file.path.replaceAll('\\', '/'), 'kind': node is EnumDeclaration ? 'enum' : node is GenericTypeAlias ? 'typedef' : node is FunctionDeclaration ? 'function' : node is MixinDeclaration ? 'mixin' : 'class', 'signature': node is EnumDeclaration || node is GenericTypeAlias ? node.toSource() : node is FunctionDeclaration ? signature(node) : source.substring(node.firstTokenAfterCommentAndMetadata.offset, node.beginToken.offset + node.length).split('{').first.trim(), 'members': entries, 'offset': node.offset, 'commentStart': node.documentationComment?.offset, 'commentEnd': node.documentationComment?.end, 'documented': node.documentationComment != null});
    }
  }
  File(args.first).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
}
