capture program drop adf2docx
program adf2docx,rclass
version 16.0

syntax varlist [if] [in] [aweight fweight iweight/] using/ [,replace title(string) note(string) fmt(string) halign(string) width1(string) width2(string)style(string)]

local num=0                  //变量计数器
foreach var of local varlist{
local num=`num'+1
local var`num'="`var'"
}

local num2=2*`num'+1        //总共需要设置的行数

	qui {
		if "`title'" == "" {
				local title = "表3 平稳性检验"
					} 

			if "`note'" == "" {
				local note="注：表中(C,T,K)表示ADF检验的检验形式，C表示检验形式为有截距、T表示检验形式为有趋势项、K表示滞后阶数，0表示不包含，∆表示一阶差分"
				
				}
			
			
				  
			if "`fmt'" == ""{
				local fmt="%6.4f"
			             }
			if "`halign'" == ""{
			   local halign="center"
			}
			if "`width1'" == ""{
				local width1="1.5pt"
			}
			if "`width2'" == ""{
				local width2="0.5pt"
			}
			if "`style'"== ""{
				local style="style1"
			}
			
		}



putdocx clear
putdocx begin
putdocx paragraph,spacing(after,0) halign(center) 
putdocx text ("`title'")


	local sig_num=0               //记录平稳的个数
	local sig_num_1=0             //记录一阶单整的个数
	local sig_num_2=0             //记录二阶单整及以上的个数
	
	local I0=""                   //装平稳变量的
	local I1=""                   //装一阶单整变量的
	local I2=""                   //装二阶单整变量的
	
	
qui{
  *第一种风格的表格
	if "`style'"=="style1"{

putdocx table tablename=(`num2',5),border(all, nil) border(top,,,`width1') ///
 halign(center) note("`note'")

putdocx table tablename(1,1)=("变量") 
putdocx table tablename(1,2)=("检验形式(C,T,K)") 
putdocx table tablename(1,3)=("ADF统计值") 
putdocx table tablename(1,4)=("P值") 
putdocx table tablename(1,5)=("结论")
putdocx table tablename(1,.),border(bottom,,,`width2')


*Schwert(1989)建议的最大滞后阶数：源自陈强P419
local Lags=floor(12*(_N/100)^(1/4))     

local bupingwen=0    //设置不平稳的初始个数
local num3=`num'+1
local ding=`num'+1    //如果都平稳，默认为


forvalues i=2/`num3'{
    local j=`i'-1
	putdocx table tablename(`i',1)=("`var`j''") 

 *开始对原始变量进行平稳性检验
local ceshi=0         //设定是否进行其他ADF形式检验的标记【原形式】
local ceshi2=0        //设定差分形式其他ADF形式检验是否继续的标记

	
    forvalues lag=0/`Lags'{
	dfuller `var`j'',lag(`lag')   //只有截距的
	cap if r(p)<0.1 {
	 putdocx table tablename(`i',2)=("(C,0,`lag')") 
	 putdocx table tablename(`i',3)=("`r(Zt)'")
	 putdocx table tablename(`i',4)=("`r(p)'")
			 putdocx table tablename(`i',5)=("平稳") 
			 local ceshi=`ceshi'+1
			 local sig_num=`sig_num'+1
			 local I0="`I0'"+" "+"`var`j''"
			 continue,break
		             }  
                  }
				  
	cap if `ceshi'==0{              
	  forvalues lag=0/`Lags'{
		dfuller `var`j'',lag(`lag') nocon  //没有截距的
		cap if r(p)<0.1 {
			 putdocx table tablename(`i',2)=("(0,0,`lag')") 
			 putdocx table tablename(`i',3)=("`r(Zt)'")
			 putdocx table tablename(`i',4)=("`r(p)'")
			 putdocx table tablename(`i',5)=("平稳") 
			 local ceshi=`ceshi'+1
			 local sig_num=`sig_num'+1
			 local I0="`I0'"+" "+"`var`j''"
			 continue,break
		             } 
                  }
	
	        }
			
	 cap if `ceshi'==0{
	  forvalues lag=0/`Lags'{
		dfuller `var`j'',lag(`lag') trend //有趋势项
			cap if r(p)<0.1 {
				 putdocx table tablename(`i',2)=("(C,T,`lag')") 
				 putdocx table tablename(`i',3)=("`r(Zt)'")
				 putdocx table tablename(`i',4)=("`r(p)'")
				 putdocx table tablename(`i',5)=("平稳") 
				 local ceshi=`ceshi'+1
				 local sig_num=`sig_num'+1
				 local I0="`I0'"+" "+"`var`j''"
				 continue,break
						 } 
					 
                            }

	              }
	   cap if `ceshi'==0 {             //已经确定不平稳了，数字应该填写的地方
				 dfuller `var`j'',lag(1) trend
				 putdocx table tablename(`i',2)=("(C,T,1)") 
				 putdocx table tablename(`i',3)=("`r(Zt)'")
				 putdocx table tablename(`i',4)=("`r(p)'")
				 putdocx table tablename(`i',5)=("不平稳") 
				 
				 local bupingwen=`bupingwen'+1
				 local ding=`num3'+`bupingwen'  
			
			
			*已经确定不平稳了，继续差分以后的操作
			*对差分后的截距
			forvalues lag2=0/`Lags'{
				dfuller d.`var`j'',lag(`lag2')   //只有截距的
			cap if r(p)<0.1 {
				putdocx table tablename(`ding',1)=("∆"+"`var`j''")
			    putdocx table tablename(`ding',2)=("(C,0,`lag2')") 
				putdocx table tablename(`ding',3)=("`r(Zt)'")
			    putdocx table tablename(`ding',4)=("`r(p)'")
			    putdocx table tablename(`ding',5)=("平稳") 
					 local ceshi2=`ceshi2'+1
					 local sig_num_1=`sig_num_1'+1
					 local I1="`I1'"+" "+"`var`j''"
					 continue,break
		             }  
                  }
			*对差分后无截距
			cap if `ceshi2'==0{              
					forvalues lag2=0/`Lags'{
						dfuller d.`var`j'',lag(`lag2') nocon  //没有截距的
		          cap if r(p)<0.1 {
			 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
			 putdocx table tablename(`ding',2)=("(0,0,`lag2')") 
			 putdocx table tablename(`ding',3)=("`r(Zt)'")
			 putdocx table tablename(`ding',4)=("`r(p)'")
			 putdocx table tablename(`ding',5)=("平稳") 
				 local ceshi2=`ceshi2'+1
				 local sig_num_1=`sig_num_1'+1
				 local I1="`I1'"+" "+"`var`j''"
			 continue,break
		             } 
                  }
	
	        }
			
			*对差分后的有趋势项、截距
			
		cap if `ceshi2'==0{
			forvalues lag2=0/`Lags'{
		      dfuller d.`var`j'',lag(`lag2') trend //有趋势项
			  cap  if r(p)<0.1 {
				 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("(C,T,`lag2')") 
				 putdocx table tablename(`ding',3)=("`r(Zt)'")
				 putdocx table tablename(`ding',4)=("`r(p)'")
				 putdocx table tablename(`ding',5)=("平稳") 
					 local ceshi2=`ceshi2'+1
					 local sig_num_1=`sig_num_1'+1
					 local I1="`I1'"+" "+"`var`j''"
				 continue,break
						 } 
					 
                            }

	              }
			cap if `ceshi2'==0{
				 dfuller d.`var`j'',lag(1) trend //有趋势项
				 local sig_num_2=`sig_num_2'+1
				 local I2="`I2'"+" "+"`var`j''"
				 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("(C,T,1)") 
				 putdocx table tablename(`ding',3)=("`r(Zt)'")
				 putdocx table tablename(`ding',4)=("`r(p)'")
				 putdocx table tablename(`ding',5)=("不平稳")
			
			}
							 
						 }
						 
					 
                            }


local ding2=`num2'-`ding'    //还有多少行空格需要删除


if `ding2'>=1{
	forvalues row=1/`ding2'{ 
	local vv=`num2'-`row'+1
    putdocx table tablename(`vv',.),drop
	}
}

putdocx table tablename(`ding',.),border(bottom,,,`width1')

*开始设置数字格式
putdocx table tablename(.,1),halign(`halign')
putdocx table tablename(.,2),halign(`halign')
putdocx table tablename(.,3),halign(`halign') nformat(`fmt')
putdocx table tablename(.,4),halign(`halign') nformat(`fmt')
putdocx table tablename(.,5),halign(`halign')
local ding_1=`ding'+1
putdocx table tablename(`ding_1'.,.),halign(left)   //这是注释

}




  *第二种风格的表格
    if "`style'"=="style2"{

putdocx table tablename=(`num2',7),border(all, nil) border(top,,,`width1') ///
 halign(center) 


putdocx table tablename(1,1)=("变量") 
putdocx table tablename(1,2)=("ADF统计值") 
putdocx table tablename(1,3)=("1%的临界值") 
putdocx table tablename(1,4)=("5%的临界值") 
putdocx table tablename(1,5)=("10%的临界值")
putdocx table tablename(1,6)=("P值")
putdocx table tablename(1,7)=("结论")
putdocx table tablename(1,.),border(bottom,,,`width2')

local Lags=floor(12*(_N/100)^(1/4))     

local bupingwen=0    //设置不平稳的初始个数
local num3=`num'+1
local ding=`num'+1    //如果都平稳，默认为

forvalues i=2/`num3'{
    local j=`i'-1
	putdocx table tablename(`i',1)=("`var`j''") 

 *开始对原始变量进行平稳性检验
local ceshi=0         //设定是否进行其他ADF形式检验的标记【原形式】
local ceshi2=0        //设定差分形式其他ADF形式检验是否继续的标记

	
    forvalues lag=0/`Lags'{
	dfuller `var`j'',lag(`lag')   //只有截距的
	cap if r(p)<0.1 {
	 putdocx table tablename(`i',2)=("`r(Zt)'") 
	 putdocx table tablename(`i',3)=("`r(cv1)'")
	 putdocx table tablename(`i',4)=("`r(cv5)'")
	 putdocx table tablename(`i',5)=("`r(cv10)'") 
	 putdocx table tablename(`i',6)=("`r(p)'")
	 putdocx table tablename(`i',7)=("平稳") 
			 local ceshi=`ceshi'+1
			 local sig_num=`sig_num'+1
			 local I0="`I0'"+" "+"`var`j''"		 
			 continue,break
		             }  
                  }
				  
	cap if `ceshi'==0{              
	  forvalues lag=0/`Lags'{
		dfuller `var`j'',lag(`lag') nocon  //没有截距的
		cap if r(p)<0.1 {
			 putdocx table tablename(`i',2)=("`r(Zt)'") 
			 putdocx table tablename(`i',3)=("`r(cv1)'")
			 putdocx table tablename(`i',4)=("`r(cv5)'")
			 putdocx table tablename(`i',5)=("`r(cv10)'") 
			 putdocx table tablename(`i',6)=("`r(p)'")
			 putdocx table tablename(`i',7)=("平稳") 
				 local ceshi=`ceshi'+1
				 local sig_num=`sig_num'+1
				 local I0="`I0'"+" "+"`var`j''"
			 continue,break
		             } 
                  }
	
	        }
			
	 cap if `ceshi'==0{
	  forvalues lag=0/`Lags'{
		dfuller `var`j'',lag(`lag') trend //有趋势项
			cap if r(p)<0.1 {
				 putdocx table tablename(`i',2)=("`r(Zt)'") 
				 putdocx table tablename(`i',3)=("`r(cv1)'")
				 putdocx table tablename(`i',4)=("`r(cv5)'")
				 putdocx table tablename(`i',5)=("`r(cv10)'") 
				 putdocx table tablename(`i',6)=("`r(p)'")
				 putdocx table tablename(`i',7)=("平稳")  
				 	 local ceshi=`ceshi'+1
					 local sig_num=`sig_num'+1
					 local I0="`I0'"+" "+"`var`j''"	
				 continue,break
						 } 
					 
                            }

	              }
	   cap if `ceshi'==0 {             //已经确定不平稳了，数字应该填写的地方
				 dfuller `var`j'',lag(1) trend
				 putdocx table tablename(`i',2)=("`r(Zt)'") 
				 putdocx table tablename(`i',3)=("`r(cv1)'")
				 putdocx table tablename(`i',4)=("`r(cv5)'")
				 putdocx table tablename(`i',5)=("`r(cv10)'") 
				 putdocx table tablename(`i',6)=("`r(p)'")
				 putdocx table tablename(`i',7)=("不平稳") 
			
				 
				 local bupingwen=`bupingwen'+1
				 local ding=`num3'+`bupingwen'  
			
			
			*已经确定不平稳了，继续差分以后的操作
			*对差分后的截距
			forvalues lag2=0/`Lags'{
				dfuller d.`var`j'',lag(`lag2')   //只有截距的
			cap if r(p)<0.1 {
				 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("`r(Zt)'")
				 putdocx table tablename(`ding',3)=("`r(cv1)'")
				 putdocx table tablename(`ding',4)=("`r(cv5)'") 
				 putdocx table tablename(`ding',5)=("`r(cv10)'") 
				 putdocx table tablename(`ding',6)=("`r(p)'")
				 putdocx table tablename(`ding',7)=("平稳") 
					 local ceshi2=`ceshi2'+1
					 local sig_num_1=`sig_num_1'+1
					 local I1="`I1'"+" "+"`var`j''"
					 continue,break
		             }  
                  }
			*对差分后无截距
			cap if `ceshi2'==0{              
					forvalues lag2=0/`Lags'{
						dfuller d.`var`j'',lag(`lag2') nocon  //没有截距的
		          cap if r(p)<0.1 {
				 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("`r(Zt)'")
				 putdocx table tablename(`ding',3)=("`r(cv1)'")
				 putdocx table tablename(`ding',4)=("`r(cv5)'") 
				 putdocx table tablename(`ding',5)=("`r(cv10)'") 
				 putdocx table tablename(`ding',6)=("`r(p)'")
				 putdocx table tablename(`ding',7)=("平稳") 
				     local ceshi2=`ceshi2'+1
					 local sig_num_1=`sig_num_1'+1
					 local I1="`I1'"+" "+"`var`j''"	
			 continue,break
		             } 
                  }
	
	        }
			
			*对差分后的有趋势项、截距
			
		cap if `ceshi2'==0{
			forvalues lag2=0/`Lags'{
		      dfuller d.`var`j'',lag(`lag2') trend //有趋势项
			  cap  if r(p)<0.1 {
			     putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("`r(Zt)'")
				 putdocx table tablename(`ding',3)=("`r(cv1)'")
				 putdocx table tablename(`ding',4)=("`r(cv5)'") 
				 putdocx table tablename(`ding',5)=("`r(cv10)'") 
				 putdocx table tablename(`ding',6)=("`r(p)'")
				 putdocx table tablename(`ding',7)=("平稳") 
					 local ceshi2=`ceshi2'+1
					 local sig_num_1=`sig_num_1'+1
					 local I1="`I1'"+" "+"`var`j''"
				 continue,break
						 } 
					 
                            }

	              }
			cap if `ceshi2'==0{
				 dfuller d.`var`j'',lag(1) trend //有趋势项
				 local sig_num_2=`sig_num_2'+1
				 local I2="`I2'"+" "+"`var`j''"
				 putdocx table tablename(`ding',1)=("∆"+"`var`j''")
				 putdocx table tablename(`ding',2)=("`r(Zt)'")
				 putdocx table tablename(`ding',3)=("`r(cv1)'")
				 putdocx table tablename(`ding',4)=("`r(cv5)'") 
				 putdocx table tablename(`ding',5)=("`r(cv10)'") 
				 putdocx table tablename(`ding',6)=("`r(p)'")
				 putdocx table tablename(`ding',7)=("不平稳") 
				
			
			                 }
							 
						 }
						 
					 
                            }

local ding2=`num2'-`ding'    //还有多少行空格需要删除


if `ding2'>=1{
	forvalues row=1/`ding2'{ 
	local vv=`num2'-`row'+1
    putdocx table tablename(`vv',.),drop
	}
}

putdocx table tablename(`ding',.),border(bottom,,,`width1')

*开始设置数字格式
putdocx table tablename(.,1),halign(`halign')
putdocx table tablename(.,2),halign(`halign') nformat(`fmt')
putdocx table tablename(.,3),halign(`halign') nformat(`fmt')
putdocx table tablename(.,4),halign(`halign') nformat(`fmt')
putdocx table tablename(.,5),halign(`halign') nformat(`fmt')
putdocx table tablename(.,6),halign(`halign') nformat(`fmt')
putdocx table tablename(.,7),halign(`halign')

 }
 
}

return scalar I0_num=`sig_num'
return scalar I1_num=`sig_num_1'
return scalar I2_num=`sig_num_2'

return local I0_name=strtrim("`I0'")
return local I1_name=strtrim("`I1'")
return local I2_name=strtrim("`I2'")

putdocx save `"`using'"',`replace'
di as txt `"ADF Test have been written to file {browse "`using'"}"'

end