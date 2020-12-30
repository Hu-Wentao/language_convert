import 'package:language_convert/utils.dart';
import 'package:test/test.dart';

void main() {
  group('变量命名风格转换 ## ', () {
    var snacks = ['alpha_test', '_alpha_test', '__alpha_test'];
    var lowerCamels = ['alphaTest', '_alphaTest', '__alphaTest'];
    var upperCamels = ['AlphaTest', '_AlphaTest', '__AlphaTest'];

    test('蛇形 -> 小驼峰', () {
      var sources = snacks;
      var matchers = lowerCamels;
      for (var i = 0; i < sources.length; i++) {
        var actual = snack2LowerCamel(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
    test('蛇形 -> 大驼峰', () {
      var sources = snacks;
      var matchers = upperCamels;
      for (var i = 0; i < sources.length; i++) {
        var actual = snack2UpperCamel(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
    test('大驼峰 -> 蛇形', () {
      var sources = upperCamels;
      var matchers = snacks;
      for (var i = 0; i < sources.length; i++) {
        var actual = upperCamel2Snack(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
    test('大驼峰 -> 小驼峰', () {
      var sources = upperCamels;
      var matchers = lowerCamels;
      for (var i = 0; i < sources.length; i++) {
        var actual = upper2LowerCamel(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
    test('小驼峰 -> 蛇形', () {
      var sources = lowerCamels;
      var matchers = snacks;
      for (var i = 0; i < sources.length; i++) {
        var actual = lowerCamel2Snack(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
    test('小驼峰 -> 大驼峰', () {
      var sources = lowerCamels;
      var matchers = upperCamels;
      for (var i = 0; i < sources.length; i++) {
        var actual = low2UpperCamel(sources[i]);
        expect(actual, matchers[i], reason: '输入参数: ${sources[i]}');
      }
    });
  });
}
