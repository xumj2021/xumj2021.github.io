---

title:       "From NOAA To Province Panel"
subtitle:    ""
description: "NOAA ISD Data Cleaning"
date:        2018-06-04
author:      ""
image:       "images/noaa.jpeg"
tags:        ["NOAA", "Geo-Economics"]
categories:  ["Tech" ]

---



最近看到Mukherjee et al. (2021, JFE) 的文章，受到了点启发，想找中国的云层数据来试试，但是没有质量特别高的数据，只好老老实实按照这篇论文中的做法从NOAA 下数据洗出来。

#### 数据来源

数据源为NCDC(美国国家气候数据中心，National Climatic Data Center)，隶属于NOAA(美国国家海洋及大气管理局，National Oceanic and Atmospheric Administration)。

数据来自NCDC的公开FTP服务器中的  ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/。

为了方便查看，文章中提到的所有数据源文件都可以在我的百度网盘分享链接里找到。

> 链接: https://pan.baidu.com/s/1GraMF6SgSg3DBIPxVNlgQQ  密码: l8j9

分析样本为 2000-2020 年间中国的地面气象数据 （每三小时记录一次）。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210330063122553.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zODQyMTg2OQ==,size_16,color_FFFFFF,t_70)

#### 原始数据结构
以2020年为例，文件命名方式为 气象站id - 99999 (NCDC WBAN Number) - 年份。![](https://img-blog.csdnimg.cn/img_convert/0291f0ac1f93f9ae17c36f400bf5f164.png)
先看一个样例文件，该文件有 9 列，其变量按顺序分别为 观测年份，观测月份，观测日期，观测小时，空气温度，露点温度，海平面气压，风向，风速，云层厚度，液体渗透深度(1小时)，液体渗透深度(6小时)。
![image-20210610102217295](https://img-blog.csdnimg.cn/img_convert/707465c364d0a4132afc86d569d1a6df.png)
详细变量说明如下：
>Introduction
><br/>
>The ISD-Lite data contain a fixed-width formatted subset of the complete Integrated Surface Data (ISD) for a select number of observational elements.  The data are typically stored in a single file corresponding to the ISD data, i.e. one file per station per year.  For more information on the ISD-Lite format, consult the ISD-Lite technical document.
><br/>
>Data Format
><br/>
>Field 1: Pos 1-4, Length 4: Observation Year
>Year of observation, rounded to nearest whole hour
><br/>
>Field 2: Pos 6-7, Length 2: Observation Month
>Month of observation, rounded to nearest whole hour
><br/>
>Field 3: Pos 9-11, Length 2: Observation Day
>Day of observation, rounded to nearest whole hour
><br/>
>Field 4: Pos 12-13, Length 2: Observation Hour
>Hour of observation, rounded to nearest whole hour
><br/>
>Field 5: Pos 14-19, Length 6:  Air Temperature
>The temperature of the air
>UNITS:  Degrees Celsius
>SCALING FACTOR: 10
>MISSING VALUE: -9999
><br/>
>Field 6: Pos 20-24, Length 6: Dew Point Temperature
>The temperature to which a given parcel of air must be cooled at constant pressure and water vapor content in order for saturation to occur.
>UNITS: Degrees Celsius
>SCALING FACTOR: 10
>MISSING VALUE: -9999
><br/>
>Field 7: Pos 26-31, Length 6: Sea Level Pressure
>The air pressure relative to Mean Sea Level (MSL).
>UNITS:  Hectopascals
>SCALING FACTOR: 10
>MISSING VALUE: -9999
><br/>
>Field 8: Pos 32-37, Length 6: Wind Direction
>The angle, measured in a clockwise direction, between true north and the direction from which the wind is blowing.
>UNITS: Angular Degrees
>SCALING FACTOR: 1
>MISSING VALUE: -9999
>*NOTE:  Wind direction for calm winds is coded as 0.
><br/>
>
>Field 9: Pos 38-43, Length 6: Wind Speed Rate
>The rate of horizontal travel of air past a fixed point.
>UNITS: meters per second
>SCALING FACTOR: 10-
	}

	local saveadd="/.../Data/Aggregate2000-2020/chinaclimate"+"`i'"
	dis "`saveadd'"
	
	* 将指定年份所有的 isd 数据存储到一个 dta 文件里
	save "`saveadd'", replace emptyok
}
```

经过这一步，得到以年为单位存储的 dta 格式的所有 isd 数据

![](https://img-blog.csdnimg.cn/img_convert/52f5e3f0796c3c4a5e4882e1edd3b8de.png)
#### Step 3: 导入 linktable, 便于将气象站 id 映射到省份
linktable 的数据样例如下
![image-20210610101811354](https://img-blog.csdnimg.cn/img_convert/4fb473bdcaf652fd100825b9f7144925.png)
#### Step 4: 处理以年为单位存储的 dta 格式的所有 isd 数据，得到每个变量年平均数据

​```stata
forvalues i = 2000/2020{
	* 遍历每个年份的 isd 数据
	use chinaclimate`i'
	drop if year=="year"
	* 删除多余的标题行
	replace station=substr(station, 1, 5)
	* 保留 stationid 的前五位，便于与 linktable 配对
	sort station
	merge station using linktable
	keep if _merge==3
	drop _merge
	* 与 linktable 配对，得到每个气象站对应的省份

	rename precipitation_depth_one_hour precipitation_one_hour
	rename precipitation_depth_six_hour precipitation_six_hour

	sort year mon day station hour
	local vars air_temperature-precipitation_six_hour
	destring `vars',replace
	* 转换为数值型变量

	global vars air_temperature dew_point_temperature sea_level_pressure wind_direction wind_speed cloud_cover precipitation_one_hour precipitation_six_hour

	foreach v of global vars{
		replace `v'=. if `v'==-9999
		* 对于每个变量，将值为 -9999 的观测替换为缺失值
		by year mon day station: egen dayave_`v'=mean(`v')
		* 对于每个观测站每个日期，求每个变量的日平均
		drop `v'
		* 只保留求日平均之后的变量
	}

	drop hour
	duplicates drop year mon day station,force
	* 对于每个观测站的每个日期，保留唯一观测
	
	foreach v of global vars{
		replace dayave_`v'=. if dayave_`v'==-9999
		* 对于每个日平均变量，将值为 -9999 的观测替换为缺失值
		bys year province: egen yearave_`v'=mean(dayave_`v')
		* 对于每个省份每个年份，求每个变量的年平均
		drop dayave_`v'
		* 只保留年平均变量
	}

	keep year province clouday yearave*
	duplicates drop year province,force
	* 对于每个观测站每个年份，保留唯一观测
	save yearclimate`i'
	* 将省份-年平均 isd 数据存储到相应年份命名的 dta 文件中
}
```

#### Step 5: 将2000-2020年所有省份-年平均 isd 数据写入一个 dta 文件中

```stata
clear
set obs 0
save yearclimate2000-2020, emptyok
local ff : dir . files "*.dta"
	foreach f of local ff {
		local tag = (substr("`f'",1,11)=="yearclimate")
		* 识别出文件夹内所有以 yearclimate 开头的 dta 文件并将其合并到一个 dta 文件里
			dis `tag'
			if `tag'==1{
				append using `f'
			}
	}
save yearclimate2000-2020, replace
```


#### 最终得到每个省份每年的平均气象数据文件
![](https://img-blog.csdnimg.cn/img_convert/5e2068267d473c5622cdde3871699733.png)