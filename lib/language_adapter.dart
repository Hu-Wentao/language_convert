// Copyright 2020-12-28, Hu-Wentao.
// Email: hu.wentao@outlook.com
// All rights reserved.

/// 语言适配器
/// 这里的参数仅针对特定编程语言的特性
/// 如 php fileStart必须是<?php
/// 而 生成某些模板代码需要在页首写入 part of xxx, 不是语言特性, 不应该写在这里
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
  filePostfix: '.d-g.php',
  fileStart: '<?php',
  fileEnd: '?>',
);

const dart_adapter = LanguageAdapter(
  annotationSymbol: '// ',
  filePostfix: '.d-g.dart',
);

const ddl_adapter = LanguageAdapter(
  annotationSymbol: '-- ',
  filePostfix: '.d-g.sql',
);
