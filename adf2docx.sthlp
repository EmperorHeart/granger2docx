
{smcl}
{* 4 Mar 2022}{...}
{hline}
help for {hi:adf2docx}
{hline}

{title:Title}

{p 4 4 2}
{bf:adf2docx} —— 极速对时间序列变量进行ADF检验,并导出标准的三线表格

{title:Syntax}

{p 4 4 2}
{cmdab:adf2docx} varlist using filename , [options]


{title:Description}

{p 4 4 2}
极速进行平稳性检验,最高只能出检验一阶单整I(1),即如果变量平稳，只显示平稳变量信息，如果变量不平稳，则进行一阶差分后在检验并汇报
其结果。检验原理为：三种检验形式,任意一种通过，即平稳。
每一种检验形式的滞后阶数从0一直循环遍历至最大的滞后阶数，
只要有一个滞后阶数可以使得P值小于0.1，则认为通过。

{title:Options}

{p 4 4 2} 
{cmd:replace} 覆盖之前同名文件 {break}
{cmd:title(string)} 填入自定义的表格名称,默认为"表3 平稳性检验" {break}
{cmd:note(string)}  填入自定义的注释,---默认注释太长，这里写不下，敬请见谅--- {break}
{cmd:fmt(string)} 填入ADF统计值和P值的小数后保留的位数，默认保留四位，例如fmt(%6.5f) {break}
{cmd:halign(string)} 填入单元格的居中方式，left表示向左看齐，right表示向右看齐，center表示向中看齐，例如：halign(left){break}
{cmd:width1(string)} 
设置三线表格的顶部线（第一条线）和底部线（第三条线）的宽度。可选单位为英里in、英镑pt、厘米cm，默认为1.5英镑，即width1(1.5pt){break}
{cmd:width2(string)} 
设置三线表格的中间线（第二条线）的宽度。默认为0.5英镑，即width2(0.5pt){break}
{cmd:style(string)} 
设置导出表的格式,style1表示从左到右变量依次是"变量,检验形式,ADF统计值,P值,结论"，style2表示从左到右变量依次是"变量,ADF统计值,1%的临界值,5%的临界值,10%的临界值,P值,结论"{break}


{title:Examples}

{p 4 4 2} *- 输出ADF检验表格!. {p_end}
{p 4 4 2}{inp:.} {stata `"sysuse auto,clear"'}{p_end}
{p 4 4 2}{inp:.} {stata `"g n=_n "'}{p_end}
{p 4 4 2}{inp:.} {stata `"tset n"'}{p_end}
{p 4 4 2}{inp:.} {stata `"adf2docx price-gear_ratio using My.docx,replace title("这是表名") note("这是注释") fmt(%7.2f) halign(center)"'}{p_end}

{title:Author}

{p 4 4 2}
{cmd:Small Emperor,Ma}{break}
毕业大学：国内某知名大学.{break}
E-mail: Stata官方无法获取该作者信息，可以点击该网址,强制获取{break}
{browse "https://www.bilibili.com/bangumi/play/ep331428?from=search&seid=6751905001257978529&spm_id_from=333.337.0.0":personal.information.checking.edu.cn } {break}

