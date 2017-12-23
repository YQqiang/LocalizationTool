# LocalizationTool
# [blog地址](http://yuqiangcoder.com/2017/12/22/LocalizationTool-%E5%9B%BD%E9%99%85%E5%8C%96%E5%B7%A5%E5%85%B7.html)
### 安装
1. 下载[LocalizationTool 源码](https://github.com/YQqiang/LocalizationTool), 使用Xcode 编译,运行. 
2. 下载[LocalizationTool dmg压缩包](https://github.com/YQqiang/LocalizationTool/releases/tag/v1.0), 解压后双击运行.

### 使用
![应用程序界面](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/1.png)

1. 导入路径
选择工程项目所在路径

2. 匹配规则说明
* 默认匹配规则为 检索 `NSLocalizedString` 包裹的字符串, 可自动根据`OC` 或 `Swift`文件切换匹配规则
* 自定义匹配规则, 可填写正则表达式进行匹配; 注: 匹配中若包含`(` `)`, 需要转义 `\(` `\)`
![自定义匹配规则](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/2.png)
* 使用前缀&后缀匹配, 输入要匹配的前缀和后缀即可自动匹配; 注: 匹配中若包含`(` `)`, 需要转义 `\(` `\)`
![输入前缀&后缀匹配](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/3.png)

3. 文件后缀
* 默认检索的文件为`.h`, `.m`, `.swift`
* 可补充需要检索的文件后缀名; 例: `xml,strings`
![补充增加检索文件后缀](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/4.png)

4. 导出路径
* 导出路径会在选择路径后创建文件夹`Localization`, 导出会有两个文件: `allKeys.txt` 和 `removedExistKey.txt`
  * `allKeys.txt`  检索到的所有key值
  * `removedExistKey.txt`  去除重复key后的文件
![导出路径](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/5.png)

5. 剔除重复key
* 默认剔除项目中所有`strings`文件中存在`key`
![默认剔除所有String文件中存在的key](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/6.png)
* 剔除指定`strings`文件中存在的`key`
![剔除指定strings文件中存在的key](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/7.png)

### 问题记录
第一次写Mac程序, 记录两个小问题😂😂😂😂😂😂😂😂
1. 写文件出错

```
Error Domain=NSCocoaErrorDomain 
Code=513 "You don’t have permission to save the file “***.txt” 
in the folder “****”." 
UserInfo={NSFilePath=/Users/dongl/Desktop/123.txt, 
NSUnderlyingError=0x608000045d90 
{Error Domain=NSPOSIXErrorDomain 
Code=1 "Operation not permitted"}}
```
解决: 关闭`TARGETS --> Capabilities --> App Sandbox`
![关闭App Sandbox](https://github.com/YQqiang/LocalizationTool/blob/master/screenshot/8.png)

2. 点击左上角叉号, 退出应用程序
在`AppDelegate`中处理

```
func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
}
```

### shell 剔除文件中重复的行
在整理国际化资源时, 国际化文件存在重复内容的行, 本来是准备撸代码遍历文件查找重复行的, 却被我们老大在终端一行脚本搞定了, 故在此记录学习下.

```
sort Localizable.strings| uniq -d > /Users/xxxx/Desktop/d.tx
参数说明: 
| 管道符
-d 查找重复的行
-u 查找唯一的行
> 重定向, 输出到文件

或者直接使用:
awk '!a[$0]++' Localizable.strings > /Users/xxxx/Desktop/d.tx
```


