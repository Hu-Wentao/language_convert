import 'dart:convert';
import 'dart:io';
import 'package:language_convert/language_adapter.dart';
import 'package:language_convert/transformer.dart';

// TODO: 添加生成信息类, 包装更多内容, 生成时间, 生成器版本, 生成类型等
class CodeBuilder {
  final LanguageAdapter otpLangAdapter; // 输出语言适配
  final bool insertGenInfo; // 是否插入生成信息
  String operate; // 被操作的数据

  CodeBuilder({
    this.otpLangAdapter,
    this.insertGenInfo = true,
  });

  CodeBuilder fromStr(String src) {
    operate = src;
    return this;
  }

  CodeBuilder fromFile(
    String fileName, {
    String inputPath = '_input/',
    Encoding encoding = utf8,
  }) {
    operate = File(fileName).readAsStringSync(encoding: encoding);
    return this;
  }

  // ---

  CodeBuilder transform(ILanguageTransformer trans) {
    operate = trans.run(operate);
    return this;
  }

  String _genInfo() {
    var dt = DateTime.now();
    return '${otpLangAdapter.annotationSymbol}Code Gen DT: ${dt.year}-${dt.month}-${dt.day}|${dt.hour}:${dt.minute}:${dt.second}';
  }

  // ---
  void _onOutput() {
    // 添加生成信息
    var gen = _genInfo();
    print(gen);
    if (otpLangAdapter.annotationSymbol == null) {
      print('未配置adapter的注释符号, 无法写入生成信息');
      return;
    }
    // 添加页头,页尾
    operate =
        '$gen\n\n${otpLangAdapter.fileStart}\n\n$operate\n${otpLangAdapter.fileEnd}';
  }

  CodeBuilder toCmd() {
    _onOutput();
    print(operate);
    return this;
  }

  CodeBuilder toFile(
    String file_path, {
    String outputPath = '_output/',
    Encoding encoding = utf8,
  }) {
    _onOutput();
    var _path = '$outputPath$file_path';
    print('文件将写入到: $_path');
    File(_path).writeAsStringSync(operate);
    return this;
  }

  CodeBuilder toFileWithAdapter(
    String fileName, {
    String genTag = 'dt-g.',
    String outputPath = '_output/',
    Encoding encoding = utf8,
  }) =>
      toFile((fileName + otpLangAdapter.filePostfix),
          outputPath: outputPath, encoding: encoding);
}

void main() {
  var adpt = dart_adapter..fileStart = 'part of \'xxxx.dart\';';
  CodeBuilder(otpLangAdapter: adpt)
      .fromFile('_input/wms_ddl.json')
      .transform(trans_ddl_js2dart_gac_repo_impl)
      .toFileWithAdapter('wms_repo_impl');
  // CodeBuilder(otpLangAdapter: php_adapter)
  //     .fromFile('wms_ddl.json')
  //     .transform(trans_ddl_js2php_entities)
  //     .toFileWithAdapter('wms');
}
