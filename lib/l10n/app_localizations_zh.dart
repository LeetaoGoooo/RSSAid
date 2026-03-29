// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get notfoundinshare => '没有发现任何链接';

  @override
  String get notfoundinClipboard => '剪贴板没有发现任何链接';

  @override
  String get fromClipboard => '从剪贴板读取';

  @override
  String get inputbyKeyboard => '手动输入';

  @override
  String get notfound => '报告主人，真的没有啦o(╥﹏╥)o';

  @override
  String get addConfig => '添加配置';

  @override
  String get submitNewRules => '提交新的规则';

  @override
  String get whichSupport => '看看支持什么规则';

  @override
  String get loadRulesFailed => '请在设置中查看规则是否成功加载';

  @override
  String get copy => '复制';

  @override
  String get copySuccess => '复制成功';

  @override
  String get copyFailed => '复制失败';

  @override
  String get subscribe => '订阅';

  @override
  String get clear => '清除所有';

  @override
  String get inputLinkChecked => '输入要检测的链接';

  @override
  String get sure => '确认';

  @override
  String get cancel => '取消';

  @override
  String get linkError => '报告主人，链接空空的';

  @override
  String get s2t => '简体转繁体';

  @override
  String get t2s => '繁体转简体';

  @override
  String get gc => '通用配置';

  @override
  String get contentFilter => '内容筛选';

  @override
  String get caseSensitive => '是否大小写敏感';

  @override
  String get fullText => '是否全文输出';

  @override
  String get sci_hub_link => '输出 Sci-hub 链接';

  @override
  String get filtering => '匹配符合条件的内容(支持正则表达式)';

  @override
  String get filter => '标题和描述';

  @override
  String get filter_title => '标题';

  @override
  String get filter_description => '描述';

  @override
  String get filter_author => '作者';

  @override
  String get filter_time => '发布时间';

  @override
  String get filter_time_hints => '仅支持数字，单位为秒';

  @override
  String get filterout => '过滤符合条件的内容(支持正则表达式)';

  @override
  String get filterout_default => '标题和描述';

  @override
  String get filterout_title => '标题';

  @override
  String get filterout_description => '描述';

  @override
  String get filterout_author => '作者';

  @override
  String get filter_others => '其他';

  @override
  String get limit_entries => '条数限制';

  @override
  String get limit_entries_hint => '只支持数字';

  @override
  String get access_control => '访问控制';

  @override
  String get csAts => '中文简繁体转换';

  @override
  String get output_format => '输出格式';

  @override
  String get rule_only_once => '仅对本次规则生效';

  @override
  String get reset_config_hint => '重置配置成功';

  @override
  String get reset => '重置';

  @override
  String get save_config_hint => '保存配置成功';

  @override
  String get update_rule => '更新规则';

  @override
  String get loading_hint => '加载中...';

  @override
  String get user_manual => '使用手册';

  @override
  String get settings => '设置';

  @override
  String get common => '通用';

  @override
  String get about => '关于';

  @override
  String get refreshRules => '更新规则';

  @override
  String get refreshingRules => '正在更新规则...';

  @override
  String get refreshRulesSuccess => '规则更新成功！';

  @override
  String get refreshRulesFailed => '规则更新失败。';

  @override
  String get preview => '预览';
}
