// Copyright 2020-12-28, Hu-Wentao.
// Email: hu.wentao@outlook.com
// All rights reserved.
import 'dart:convert';

import 'package:language_convert/utils.dart' as utils;

///
/// 语言转换类
abstract class ILanguageTransformer {
  String run(String src);
}

typedef DdlConvert = String Function(Map<String, dynamic> ddl);

class DdlJsonTransformer extends ILanguageTransformer {
  final DdlConvert convertByDdl;

  DdlJsonTransformer(this.convertByDdl);

  @override
  String run(String src) {
    var all_dict = json.decode(src);
    var all_r = [];
    for (var ddl in all_dict) {
      all_r.add(convertByDdl(ddl));
    }
    return all_r.join('');
  }
}

// ---

/// 数据库DDL -> PHP实体类
final trans_ddl2php_entities = DdlJsonTransformer((Map<String, dynamic> ddl) {
  var clz = utils.snack2UpperCamel(ddl['table'].toString());
  var fls = ddl['fields'] as List;
  // --
  var c_head_ln = 'class $clz\n{';
  var c_fld_lns = [];
  for (var fld in fls) {
    var name = fld['field'];
    var fl_ln = '    private \$$name;\n';
    c_fld_lns.add(fl_ln);
  }
  var c_fld_gc_lns = [];

  for (var fld in fls) {
    var name = fld['field'];
    var up_name = utils.low2UpperCamel(name);
    var fl_get_ln = (''
        '\n    public function get$up_name()'
        '\n    {'
        '\n        return \$this->$name;'
        '\n    }\n');
    var fl_set_ln = (''
        '\n    public function set$up_name(\$$name)'
        '\n    {'
        '\n        \$this->$name = \$$name;'
        '\n    }\n');
    c_fld_gc_lns.add(fl_get_ln + fl_set_ln);
  }
  var _code_list = [
    c_head_ln,
    '\n',
    ...c_fld_lns,
    '\n',
    ...c_fld_gc_lns,
    '\n',
    '}\n',
  ];
  return _code_list.join('');
});
