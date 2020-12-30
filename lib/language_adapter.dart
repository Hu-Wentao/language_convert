// Copyright 2020-12-28, Hu-Wentao. 
// Email: hu.wentao@outlook.com
// All rights reserved.

/// 语言适配器
class LanguageAdapter {
  final String annotationSymbol;
  final String filePostfix;
  final String fileStart;
  final String fileEnd;

  const LanguageAdapter({
    this.annotationSymbol = '# ',
    this.filePostfix,
    this.fileStart,
    this.fileEnd,
  });
}

// ---


const php_adapter = LanguageAdapter(
  annotationSymbol: '// ',
  filePostfix: '.d_g.php',
  fileStart: '<?php',
  fileEnd: '?>',
);

const dart_adapter = LanguageAdapter(
  annotationSymbol: '// ',
  filePostfix: '.d_g.dart',
);

const ddl_adapter = LanguageAdapter(
  annotationSymbol: '-- ',
  filePostfix: '.d_g.sql',
);