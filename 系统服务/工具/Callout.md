---
description: 仓库的基本操作工具
created: 2026-10-06 星期二 15:17
modified: 2026-10-30 星期五 18:12
published: false
tags: []
---

## Callout CSS
**隐藏标题列写法**：`> [!blank-container]`

> [!multi-column]
>
>> [!tip] 这是第一个分栏
>> **嵌入一个无序列表**
>>>[!tip] 嵌套一个无序列表
>>> 	- 这是二级无序列表
>>> 		- 这是三级无序列表
>> 
>> **复选框语法**
>>>[!tip]  这里用的嵌套 callout
>>> - [ ] 新建任务 
>>>  - [/] 正在进行
>>>  - [x] 任务完成
>>>  - [-] 任务取消 
>> 
>>   **靠右签名**
>>>[!note|cite] 签名靠右
>>>  任意 callout 语法加 `|cite`，内容与作者之间加一个空行
>>>  
>>>  这里是签名
>>
> 
>> [!tip] 这是第二个分栏
>>**嵌入一篇笔记**
>>  ![[线下活动经验集]]
> 
>> [!tip] 这的第三个分栏
>> **仓库 Git 初始化**
>>> [!code] 内嵌代码快
>>>
>>> ```md
>>> # 1. 进入项目文件夹
>>> cd 到你的LessLive文件夹目录
>>> # 2. 【如果还没全局配置身份，执行一次，以后就不用了】
>>> git config --global user.name "nian"
>>> git config --global user.email "你的邮箱@xxx.com"
>>> # 3. 初始化仓库
>>> git init
>>> # 4. 创建 .gitignore
>>> touch .gitignore
>>> # 5. 添加文件、提交
>>> git add .
>>> git commit -m "初始化仓库"
>>> # 6.（可选）关联远程仓库
>>> git remote add origin git@github.com:xxx/xxx.git
>>> git push -u origin main
>>>  ```

---