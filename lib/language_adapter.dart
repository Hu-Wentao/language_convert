// Copyright 2020-12-28, Hu-Wentao.
// Email: hu.wentao@outlook.com
// All rights reserved.

/// 语言适配器
class LanguageAdapter {
  final String annotationSymbol;
  final String filePostfix;
  String fileStart;
  String fileEnd;

  LanguageAdapter({
    this.annotationSymbol = '# ',
    this.filePostfix,
    this.fileStart,
    this.fileEnd,
  });
}

// ---

final php_adapter = LanguageAdapter(
  annotationSymbol: '// ',
  filePostfix: '.d_g.php',
  fileStart: '<?php',
  fileEnd: '?>',
);

final dart_adapter = LanguageAdapter(
  annotationSymbol: '// ',
  filePostfix: '.d_g.dart',
);

final ddl_adapter = LanguageAdapter(
  annotationSymbol: '-- ',
  filePostfix: '.d_g.sql',
);
