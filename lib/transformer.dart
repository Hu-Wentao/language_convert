// Copyright 2020-12-28, Hu-Wentao.
// Email: hu.wentao@outlook.com
// All rights reserved.
import 'dart:convert';

import 'package:language_convert/utils.dart' as utils;

import 'language_adapter.dart';

// TODO: 包装更多内容, 生成类型等
class BaseOutputInfoFormat {
  String _genTimeLine(LanguageAdapter lastAdapter) {
    var dt = DateTime.now();
    return 'Code Gen DT: ${dt.year}-${dt.month}-${dt.day} || ${dt.hour}:${dt.minute}:${dt.second}';
  }

  String genTransInfo(ILanguageTransformer trans) =>
      '生成器: ${trans.runtimeType} || '
      '版本: ${trans.transVersion}\n';

  List<String> getInfoLines(List<ILanguageTransformer> transHistory) {
    var lastAdapter = transHistory?.last?.adapter;
    return lastAdapter == null
        ? null
        : [
            _genTimeLine(lastAdapter),
            ...transHistory.map((t) => genTransInfo(t)),
          ];
  }
}

///
/// 语言转换类
abstract class ILanguageTransformer {
  final String transVersion;
  final LanguageAdapter adapter;

  ILanguageTransformer(this.adapter, this.transVersion);

  String run(String src);
}

abstract class DdlJsonTransformer extends ILanguageTransformer {
  DdlJsonTransformer(LanguageAdapter adapter, String transVersion)
      : super(adapter, transVersion);

  String get pageStart => null;

  String get pageEnd => null;

  String convertByDdl(Map<String, dynamic> ddl);

  @override
  String run(String src) {
    var all_dict = json.decode(src);
    var all_r = [];
    all_r.add(pageStart ?? '');
    for (var ddl in all_dict) {
      all_r.add(convertByDdl(ddl));
    }
    all_r.add(pageEnd ?? '');
    return all_r.join('');
  }
}

// ---

///  DDL -> GacRepoImpl
class TransDdlJs2DartGacRepoImpl extends DdlJsonTransformer {
  // part 文件名(不包含.dart后缀)
  final String partOf;

  TransDdlJs2DartGacRepoImpl({this.partOf}) : super(dart_adapter, 'v2');

  @override
  String get pageStart =>
      partOf != null ? 'part of \'${partOf}.dart\';\n\n' : '';

  @override
  String convertByDdl(Map<String, dynamic> ddl) {
    var clz = utils.snack2UpperCamel(ddl['table'] as String);
    var under_clz = utils.upperCamel2Snack(clz);

    var c_anno_ln = '@LazySingleton(as: I${clz}Repo)';
    var c_head_ln = 'class ${clz}RepoImpl extends I${clz}Repo {';
    var c_crt_method_ln = ('\n  @override'
        '\n  Future <${clz}> create(${clz} entity) async {'
        '\n    var dto = ${clz}Dto.fromDM(entity);'
        '\n    var id = getUuid();'
        '\n    var r = await _sqlClient'
        "\n        .table('${under_clz}')"
        '\n        .insert(dto.toJson().appendUuid(uuid: id));'
        '\n    return dto.copyWith(id: id).toDomain();'
        '\n  }');
    var c_del_method_ln = ('\n  @override'
        '\n  Future <Unit> delete(String id) async {'
        '\n    var r = await _sqlClient'
        "\n        .table('${under_clz}')"
        "\n        .whereColumn('id', equals: id)"
        '\n        .deleteAll();'
        '\n    return null;'
        '\n  }');
    var c_update_method_ln = ('\n  @override'
        '\n  Future<${clz}> update(${clz} item) async {'
        '\n    if (item.id == null) throw StorageFailure(\'被更新的对象id不能为null\');'
        '\n    // 查询'
        '\n    if((await read(item.id))!=null) await delete(item.id);'
        '\n    return await create(item);'
        '\n  }');
    var c_read_method_ln = ('\n  @override'
        '\n  Future <${clz}> read(String id) async {'
        '\n    var r = await _sqlClient'
        "\n        .table('${under_clz}')"
        "\n        .whereColumn('id', equals: id)"
        '\n        .select()'
        '\n        .toMaps();'
        '\n    if (r.length == 0) {'
        '\n      return null;'
        '\n    } else if (r.length == 1) {'
        '\n      var js = r[0];'
        '\n      var dm = ${clz}Dto.fromJson(js).toDomain();'
        '\n      return dm;'
        '\n    } else {'
        "\n      throw StorageFailure('通过id查询到了多个返回值!');"
        '\n    }'
        '\n  }');
    var c_query_by_ln = ('\n  @override'
        '\n  Future<List<${clz}>> query({int limit = null, int offset = 0}) async {'
        '\n    var r = await _sqlClient'
        "\n        .table('${under_clz}')"
        '\n        .limit(limit)'
        '\n        .offset(offset)'
        '\n        .select()'
        '\n        .toMaps();'
        '\n    return r?.map((js) => ${clz}Dto.fromJson(js).toDomain())?.toList();'
        '\n  }');

    var c_end_ln = '}\n';
    var _code_list = [
      c_anno_ln,
      '\n',
      c_head_ln,
      '\n',
      c_crt_method_ln,
      '\n',
      c_del_method_ln,
      '\n',
      c_update_method_ln,
      '\n',
      c_read_method_ln,
      '\n',
      c_query_by_ln,
      '\n',
      c_end_ln
    ];
    return _code_list.join('');
  }
}

/// 数据库DDL -> PHP实体类
class TransDdlJs2PhpEntity extends DdlJsonTransformer {
  TransDdlJs2PhpEntity() : super(php_adapter, 'v1');

  @override
  String convertByDdl(Map<String, dynamic> ddl) {
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
  }
}
