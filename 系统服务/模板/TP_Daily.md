---
description:
created: 2026-09-26 星期六 16:39
modified: 2026-10-08 星期四 22:31
published: false
tags: [Daily, todo]
aliases: []
mood: 0
Exercise: false
---
用日志命名，避免把 LessLive 仓库当做传统日记，这里不必[[每日]] 记录
# Good Morning

> [!multi-column] 
> > [!info]  昨天过的怎么样
> > 
> 
> > [!info] 今天打算怎么过
> >  

# 今天只做一件事
`从一堆任务里蒸馏出权重最高的那件事`

> [!info] One Thing Taday
>  

# 今天的行动计划

- [ ] 

# 今天的成就清单
`额外完成的其他任务作为自己的奖励`
1. 

# 有什么想说的吗

1. 

# 心情和习惯地图

## **MOOD**


---

```dataviewjs

const calendarData = {

    intensityScaleStart: 1,
    intensityScaleEnd: 6,
    colors: {
        red2green: [
            "#004D21","#196C2E", "#007B34", "#009a42","#02B302","#00e763"
        ],
    },
    entries: []
}

for(let page of dv.pages('"系统服务/日志/每日"').where(p=>p.mood)){ 

    calendarData.entries.push({
        date: page.file.name.substring(0,10), 
        intensity: page.mood,
        content: await dv.span(`[[${page.file.name}|]]`), //悬停显示，点击跳转
    })
      
}

renderHeatmapCalendar(this.container, calendarData)

```

---

## **EXERCISE**

---

```dataviewjs

const calendarData = {
    colors: {
        white: ["#169F92"],
    },
    entries: []
}

for(let page of dv.pages('"系统服务/日志/每日"').where(p=>p.Exercise)){
	 
    calendarData.entries.push({
        date: page.file.name.substring(0,10),
        content: await dv.span(`[[${page.file.name}|✅]]`), //显示打卡完成
    }) 
}
	
renderHeatmapCalendar(this.container, calendarData)

```

---

# 最近一周的笔记

```dataviewjs
// 排除不需要显示的文件夹和文件
const excludeItems = ["系统服务", "系统/模板/", "系统/字体/", "系统/附件/", "Tags/", "模型/第二课题/日志/", "Index"];
// 设置每页显示的结果数量
const pageSize = 8;

// 筛选符合条件的笔记（过去一周创建或修改的）
const allFilteredNotes = dv.pages()
    .where(p =>
        !excludeItems.some(item =>
            item.endsWith("/")
                ? p.file.path.includes(item)
                : p.file.name.replace(".md", "") === item
        ) &&
        (p.file.ctime >= dv.date("now") - dv.duration("1 week") ||
            p.file.mtime >= dv.date("now") - dv.duration("1 week"))
    )
    .sort(p => p.file.mtime, "desc");

// 如果没有结果，显示提示信息
if (allFilteredNotes.length === 0) {
    dv.paragraph("过去一周没有更新或创建的笔记。");
} else {
    // 显示第一页结果
    const visibleNotes = allFilteredNotes.slice(0, pageSize);
    dv.table(
        ["笔记", "创建", "修改", "发布", "任务"],
        visibleNotes.map(p => [
            p.file.link,
            p.file.ctime.toLocaleString(),
            p.file.mtime.toLocaleString(),
            p.published === true ? "✅" : "☐",
            p.file.tasks
                ? `${p.file.tasks.where(t => t.completed).length}/${p.file.tasks.length}`
                : "0/0"
        ])
    );

    // 如果有更多结果，显示折叠面板和包含剩余结果的嵌套查询块
    if (allFilteredNotes.length > pageSize) {
        const hiddenNotes = allFilteredNotes.slice(pageSize);
        // 嵌套的dataviewjs代码，表格列要和上面保持一致
        const hiddenCode = `
\`\`\`dataviewjs
// 排除不需要显示的文件夹和文件 (与主查询一致)
const excludeItems = ${JSON.stringify(excludeItems)};
// 获取所有符合条件的笔记 (与主查询一致)
const allFilteredNotes = dv.pages()
    .where(p =>
        !excludeItems.some(item =>
            item.endsWith("/")
                ? p.file.path.includes(item)
                : p.file.name.replace(".md", "") === item
        ) &&
        (p.file.ctime >= dv.date("now") - dv.duration("1 week") ||
            p.file.mtime >= dv.date("now") - dv.duration("1 week"))
    )
    .sort(p => p.file.mtime, "desc");
// 获取剩余笔记
const hiddenNotes = allFilteredNotes.slice(${pageSize});
// 渲染表格
dv.table(
    ["笔记", "创建", "修改", "发布", "任务"],
    hiddenNotes.map(p => [
        p.file.link,
        p.file.ctime.toLocaleString(),
        p.file.mtime.toLocaleString(),
        p.published === true ? "✅" : "☐",
        p.file.tasks
            ? \`\${p.file.tasks.where(t => t.completed).length}/\${p.file.tasks.length}\`
            : "0/0"
    ])
);
\`\`\``;
        dv.paragraph(`<hr><details><summary>查看更多结果 (${hiddenNotes.length} 条)</summary>\n${hiddenCode}\n</details>`);
    }
}

```