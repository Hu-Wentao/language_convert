import 'dart:convert';
import 'dart:io';
import 'package:language_convert/transformer.dart';

class CodeBuilder {
  final bool insertGenInfo; // 是否插入生成信息

  BaseOutputInfoFormat outputInfoFmt; // 输出信息格式化
  List<ILanguageTransformer> transHistory = []; // 转换历史
  String operate; // 被操作的数据

  CodeBuilder({
    this.outputInfoFmt,
    this.insertGenInfo = true,
  }) {
    outputInfoFmt ??= BaseOutputInfoFormat();
  }

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
    transHistory.add(trans);
    operate = trans.run(operate);
    return this;
  }

  // ---
  void _onOutput() {
    // 添加生成信息
    var gen = outputInfoFmt.getInfo(transHistory) ?? '没有转换, 无法生成转换信息';
    print(gen);

    var adapter = transHistory.last?.adapter;
    if (adapter.annotationSymbol == null) {
      print('未配置adapter的注释符号, 无法写入生成信息');
      return;
    }
    // 添加页头,页尾
    operate =
        '$gen\n${adapter.fileStart ?? ''}\n$operate\n${adapter.fileEnd ?? ''}';
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
      toFile((fileName + transHistory.last.adapter.filePostfix),
          outputPath: outputPath, encoding: encoding);
}

void main() {
  CodeBuilder()
      .fromFile('_input/wms_ddl.json')
      .transform(TransDdlJs2DartGacRepoImpl(partOf: 'xxx'))
      .toFileWithAdapter('wms_repo_impl');
}
