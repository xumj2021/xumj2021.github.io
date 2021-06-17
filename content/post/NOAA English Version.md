---

title:       "From NOAA ISD Dataset to Panel Data - English Version"
subtitle:    ""
description: "China Stations As An Example"
date:        2021-06-15
author:      "Mengjie Xu"
image:       "https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/space-communications-satellite-earth-featured.jpeg"
tags:        ["NOAA", "Geo-Economics"]
categories:  ["papers" ]

---



#### Motivation

The motivation to clean this dataset is from [Mukherjee et al. (2021, JFE)](https://www.sciencedirect.com/science/article/pii/S0304405X21000921). In this paper, the authors documented that one can get ahead-of-announcement estimation about the storage hubs for crude oil in the US from satellite images and trade on it. This will decrease the market reaction around the release of official figures because the oil storage information has been partially revealed during the traders' arbitrage before announcement due to traders' use of satellite images. To establish the causality between traders' satellite image use and the lower market reaction around official figure release, this paper adopted cloudiness in the storage sites as Instrument Variable because the satellite images will be more obscure and thus less useful when the weather is cloudy. It turns out that the lowered market reaction is indeed less prominent during cloudy weeks. 

In this article, I tried to construct a high-frequency cloudiness variable following the Mukherjee paper.



#### Data Source

The original data source is [National Oceanic and Atmospheric Administration](https://www.ncdc.noaa.gov/isd) and I downloaded the Integrated Surface Database (ISD) dataset from its [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/).



##### Brief Introduction to ISD dataset

> The Integrated Surface Database (ISD) consists of global hourly and synoptic observations compiled from numerous sources into a single common ASCII format and common data model.
>
> <br>
>
> The database includes over 35,000 stations worldwide, with some having data as far back as 1901, though the data show a substantial increase in volume in the 1940s and again in the early 1970s. Currently, there are over 14,000 "active" stations updated daily in the database. 
>
> <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Integrated-Surface-Database-Stations-Over-Time-Chart.jpeg"/><br>Station Number</center>



##### Subsample Used In This Article

- Period: 2000 - 2020
- Station Range: 2168 Stations located in China (Range from 50136 to 59951)
- Freqency: Every 3 hours



##### Original Data Structure

- The folders are named by year

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.18.12.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 1: NOAA Folder List</div>
  </center>

- For each year, there is individual file for each station

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.24.28.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 2: NOAA ISD File List</div>
  </center>

- For each file in a given year, the naming format is "Station ID-NCDC WBAN Number-Year"

- For each file (with a relative station id and year), there are 12 columns

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.39.34.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 3: Sample ISD File</div>
  </center>

  

- Variable Definitions

  > Integrated Surface Data - Lite 
  > <br>Format Documentation
  > <br><br>
  > <br>June 20, 2006
  > <br>
  > <br>Introduction
  > <br><br>The ISD-Lite data contain a fixed-width formatted subset of the complete Integrated Surface Data (ISD) for a select number of observational elements.  The data are typically stored in a single file corresponding to the ISD data, i.e. one file per station per year.  For more information on the ISD-Lite format, consult the ISD-Lite technical document.
  > <br><br>Data Format
  > <br><br>Field 1: Pos 1-4, Length 4: Observation Year
  > <br>Year of observation, rounded to nearest whole hour
  > <br><br>Field 2: Pos 6-7, Length 2: Observation Month
  > <br>Month of observation, rounded to nearest whole hour
  > <br><br>Field 3: Pos 9-11, Length 2: Observation Day
  > <br>Day of observation, rounded to nearest whole hour
  > <br><br>Field 4: Pos 12-13, Length 2: Observation Hour
  > <br>Hour of observation, rounded to nearest whole hour
  > <br><br>Field 5: Pos 14-19, Length 6:  Air Temperature
  > <br>The temperature of the air
  > <br>UNITS:  Degrees Celsius
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 6: Pos 20-24, Length 6: Dew Point Temperature
  > <br>The temperature to which a given parcel of air must be cooled at constant pressure and water vapor content in order for saturation to occur.
  > <br>UNITS: Degrees Celsius
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 7: Pos 26-31, Length 6: Sea Level Pressure
  > <br>The air pressure relative to Mean Sea Level (MSL).
  > <br>UNITS:  Hectopascals
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 8: Pos 32-37, Length 6: Wind Direction
  > <br>The angle, measured in a clockwise direction, between true north and the direction from which the wind is blowing.
  > <br>UNITS: Angular Degrees
  > <br>SCALING FACTOR: 1
  > <br>MISSING VALUE: -9999
  > <br>*NOTE:  Wind direction for calm winds is coded as 0.
  > <br><br>
  > <br>Field 9: Pos 38-43, Length 6: Wind Speed Rate
  > <br>The rate of horizontal travel of air past a fixed point.
  > <br>UNITS: meters per second
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 10: Pos 44-49, Length 6: Sky Condition Total Coverage Code
  > <br>The code that denotes the fraction of the total celestial dome covered by clouds or other obscuring phenomena.
  > <br>MISSING VALUE: -9999
  > <br>DOMAIN:
  > <br>0: None, SKC or CLR
  > <br>1: One okta - 1/10 or less but not zero
  > <br>2: Two oktas - 2/10 - 3/10, or FEW
  > <br>3: Three oktas - 4/10
  > <br>4: Four oktas - 5/10, or SCT
  > <br>5: Five oktas - 6/10
  > <br>6: Six oktas - 7/10 - 8/10
  > <br>7: Seven oktas - 9/10 or more but not 10/10, or BKN
  > <br>8: Eight oktas - 10/10, or OVC
  > <br>9: Sky obscured, or cloud amount cannot be estimated
  > <br>10: Partial obscuration
  > <br>11: Thin scattered
  > <br>12: Scattered
  > <br>13: Dark scattered
  > <br>14: Thin broken
  > <br>15: Broken
  > <br>16: Dark broken
  > <br>17: Thin overcast
  > <br>18: Overcast
  > <br>19: Dark overcast
  > <br><br>Field 11: Pos 50-55, Length 6: Liquid Precipitation Depth Dimension - One Hour Duration
  > <br>The depth of liquid precipitation that is measured over a one hour accumulation period.
  > <br>UNITS: millimeters
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br>*NOTE*:  Trace precipitation is coded as -1
  > <br><br>Field 12: Pos 56-61, Length 6: Liquid Precipitation Depth Dimension - Six Hour Duration
  > <br>The depth of liquid precipitation that is measured over a six hour accumulation period.
  > <br>UNITS: millimeters
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br>*NOTE*:  Trace precipitation is coded as -1



#### Processing Data

##### Preparing Data

As the number of ISD files is too big, it will create too many redundent `dta` files when writing those datasets into `Stata`. Here I wrote all the ISD files recording data for the same first two-digit station ids in a same year into a new file, named by the first two-digit of station ids and store it into the folder "china_isd_lite_" + the respect year.

```python
import os
import csv

dir = "/.../Data/"
# isd 文件存储路径

headline = ['year','mon','day','hour','air_temperature','dew_point_temperature',
            'sea_level_pressure','wind_direction','wind_speed','cloud_cover',
            'precipitation_depth_one_hour','precipitation_depth_six_hour','station']
# 标题行

def transisd2csv(year):
    g = os.walk(dir + "china_isd_lite_%s"%year)
    # 遍历指定年份isd文件夹内所有文件
    isExists = os.path.exists(dir + "Aggregate%s/" % year)
    if not isExists:
        os.makedirs(dir + "Aggregate%s/" % year)
    # 如果没有指定年份 Aggregate 文件夹，则创建一个
    for path, dir_list, file_list in g:
        for file_name in file_list:
            if file_name!=".DS_Store":
                station = file_name.split("-")[0]
                # 从每个 isd 文件名中提取气象站 id
                csvFile = open(dir + "Aggregate%s/r%s.csv" % (year, station[:2]), "a", newline='', encoding='utf-8')
                # 命名一个以气象站id前两位命名的csv文件，如果没有则创建一个，存储到前面创建的 Aggregate 文件夹中
                writer = csv.writer(csvFile)
                writer.writerow(headline)
                # 写入标题行
                f = open(dir + "china_isd_lite_%s/" % year + file_name, "r")
                # 逐个打开指定年份isd文件夹中的每个文件
                for line in f:
                  	# 对于每个打开的 isd 文件，逐行读取数据
                    csvRow = line.split()
                    # 对于每一行，以空格分割，得到该行数据的 list 形式
                    csvRow.append(station)
                    # 每列末尾加上气象站 id
                    writer.writerow(csvRow)
                    # 向之前创建的 csv 文件里写入每行数据


for year in range(2000,2021):
    transisd2csv(year)
    print("Year %s completed"%year)
```

