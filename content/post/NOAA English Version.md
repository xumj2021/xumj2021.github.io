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
> The database includes over 35,000 stations worldwide, with some having data as far back as 1901, though the data show a substantial increase in volume in the 1940s and again in the early 1970s. Currently, there are over 14,000 "active" stations updated daily in the database. 
>
> <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Integrated-Surface-Database-Stations-Over-Time-Chart.jpeg"/><br>Station Number</center>



##### Subsample Used In This Article

- Period: 2000 - 2020
- Station Range: 2168 Stations located in China (Range from 50136 to 59951)
- Freqency: Every 3 hours



##### Original Data Structure

- The folders are named by year

  <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.18.12.png"/><br>NOAA FTP Folder List</center>

- For each year, there is individual file for each station

  <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.24.28.png"/><br>NOAA ISD File List</center>

- For each file in a given year, the naming format is "Station ID-NCDC WBAN Number-Year"

- For each file (with a relative station id and year), there are 12 columns

  <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.39.34.png"/><br>Sample ISD File</center>

- Variable Definitions

  > Integrated Surface Data - Lite 
  > Format Documentation
  > <br/>
  >
  > June 20, 2006
  >
  > Introduction
  > <br/>
  > The ISD-Lite data contain a fixed-width formatted subset of the complete Integrated Surface Data (ISD) for a select number of observational elements.  The data are typically stored in a single file corresponding to the ISD data, i.e. one file per station per year.  For more information on the ISD-Lite format, consult the ISD-Lite technical document.
  > <br/>
  > Data Format
  > <br/>
  > Field 1: Pos 1-4, Length 4: Observation Year
  > Year of observation, rounded to nearest whole hour
  > <br/>
  > Field 2: Pos 6-7, Length 2: Observation Month
  > Month of observation, rounded to nearest whole hour
  > <br/>
  > Field 3: Pos 9-11, Length 2: Observation Day
  > Day of observation, rounded to nearest whole hour
  > <br/>
  > Field 4: Pos 12-13, Length 2: Observation Hour
  > Hour of observation, rounded to nearest whole hour
  > <br/>
  > Field 5: Pos 14-19, Length 6:  Air Temperature
  > The temperature of the air
  > UNITS:  Degrees Celsius
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > <br/>
  > Field 6: Pos 20-24, Length 6: Dew Point Temperature
  > The temperature to which a given parcel of air must be cooled at constant pressure and water vapor content in order for saturation to occur.
  > UNITS: Degrees Celsius
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > <br/>
  > Field 7: Pos 26-31, Length 6: Sea Level Pressure
  > The air pressure relative to Mean Sea Level (MSL).
  > UNITS:  Hectopascals
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > <br/>
  > Field 8: Pos 32-37, Length 6: Wind Direction
  > The angle, measured in a clockwise direction, between true north and the direction from which the wind is blowing.
  > UNITS: Angular Degrees
  > SCALING FACTOR: 1
  > MISSING VALUE: -9999
  > *NOTE:  Wind direction for calm winds is coded as 0.
  > <br/>
  >
  > Field 9: Pos 38-43, Length 6: Wind Speed Rate
  > The rate of horizontal travel of air past a fixed point.
  > UNITS: meters per second
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > <br/>
  > Field 10: Pos 44-49, Length 6: Sky Condition Total Coverage Code
  > The code that denotes the fraction of the total celestial dome covered by clouds or other obscuring phenomena.
  > MISSING VALUE: -9999
  > DOMAIN:
  >  0: None, SKC or CLR
  >  1: One okta - 1/10 or less but not zero
  >  2: Two oktas - 2/10 - 3/10, or FEW
  >  3: Three oktas - 4/10
  >  4: Four oktas - 5/10, or SCT
  >  5: Five oktas - 6/10
  >  6: Six oktas - 7/10 - 8/10
  >  7: Seven oktas - 9/10 or more but not 10/10, or BKN
  >  8: Eight oktas - 10/10, or OVC
  >  9: Sky obscured, or cloud amount cannot be estimated
  > 10: Partial obscuration
  > 11: Thin scattered
  > 12: Scattered
  > 13: Dark scattered
  > 14: Thin broken
  > 15: Broken
  > 16: Dark broken
  > 17: Thin overcast
  > 18: Overcast
  > 19: Dark overcast
  > <br/>
  > Field 11: Pos 50-55, Length 6: Liquid Precipitation Depth Dimension - One Hour Duration
  > The depth of liquid precipitation that is measured over a one hour accumulation period.
  > UNITS: millimeters
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > *NOTE:  Trace precipitation is coded as -1
  > <br/>
  > Field 12: Pos 56-61, Length 6: Liquid Precipitation Depth Dimension - Six Hour Duration
  > The depth of liquid precipitation that is measured over a six hour accumulation period.
  > UNITS: millimeters
  > SCALING FACTOR: 10
  > MISSING VALUE: -9999
  > *NOTE:  Trace precipitation is coded as -1
  > <br/>

