---

title:       "Get Shareholder Activism Data From SEC EDGAR "
subtitle:    ""
description: "Crawling SC-13D Files"
date:        2021-06-13
author:      ""
image:       "static/shareholder.png"
tags:        ["SEC", "Shareholder"]
categories:  ["Tech" ]

---



写论文的时候需要搞一个 shareholder activism 变量，但是学校没买。看了下 Brav et al. (2018 JFE)，发现这个数据是直接从 SEC EDGAR 的 13D 文件整理的，等图书馆订要好几天，索性自己爬了。

#### 获取 Cookies

我一般用 Selenium 获取 cookies，这种方法自动化，而且几乎对任何网站都适用。对于 EDGAR，由于默认只显示文件名称，文件日期和涉及实体的名称。打开网页后，需要下拉页面勾选 CIK，FIle number 等其他你需要的选项。其中最关键的是 CIK ，这是链接 SEC File 和其他财务数据库 (Compustat，CRSP 等) 的关键识别变量。

打开 [源网址](https://www.sec.gov/edgar/search/#/dateRange=custom&category=custom&startdt=2001-01-01&enddt=2021-05-27&forms=SC%252013)  后呈现的页面如下

![image-20210610135001530](http://ww1.sinaimg.cn/large/008iTKOogy1grdg610cu4j31wi0usk9h.jpg)

下拉默认只有三列数据

![](http://ww1.sinaimg.cn/large/008iTKOogy1grdgifjrxij31gq0h2449.jpg)

勾选了其他数据栏后会呈现多列数据，相应的 Cookies 也会发现变化

![勾选后](http://ww1.sinaimg.cn/large/008iTKOogy1grdgayv1vnj31z40g0q6m.jpg)

代码

```python
from selenium import webdriver
import time
import json

option = webdriver.FirefoxOptions()
option.add_argument('-headless')
driver = webdriver.Firefox(executable_path='/Users/mengjiexu/Dropbox/Pythoncodes/geckodriver')

driver.get("https://www.sec.gov/edgar/search/#/dateRange=custom&category=custom&startdt=2001-01-01&enddt=2021-05-27&forms=SC%252013D")
# 打开源网页

time.sleep(3)
driver.execute_script('window.scrollTo(0,500)')
# 向下拉到勾选位置
time.sleep(2)
driver.find_element_by_xpath("//input[@value='cik']").click() 
# 点选 CIK
driver.find_element_by_xpath("//input[@value='file-num']").click() 
# 点选 File number
time.sleep(2)

# 记录 cookies 并写入 txt 文件中
orcookies = driver.get_cookies()
print(orcookies)
cookies = {}
for item in orcookies:
    cookies[item['name']] = item['value']
with open("edgarcookies.txt", "w") as f:
    f.write(json.dumps(cookies))

driver.close()
```



#### 获取 Json

从 search-index 中可以找到返回的 Json 源

![image-20210610135913826](http://ww1.sinaimg.cn/large/008iTKOogy1grdgbah4eoj31z20e0n77.jpg)

翻到第二页，Fetch 得到 post 的参数信息，这里关键是是 headers 和 body

```
await fetch("https://efts.sec.gov/LATEST/search-index", {
    "credentials": "omit",
    "headers": {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "en-US,en;q=0.5",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
    },
    "referrer": "https://www.sec.gov/",
    "body": "{\"dateRange\":\"custom\",\"category\":\"custom\",\"startdt\":\"2001-01-01\",\"enddt\":\"2021-05-27\",\"forms\":[\"SC 13D\"],\"page\":\"2\",\"from\":100}",
    "method": "POST",
    "mode": "cors"
});
```

body 里包含了向服务器 post 的查询参数，包括

- 查询起始日期 startdt / enddt
- 文件类型 forms = SC 13D
- 当前页数 page 
- 前续页数 from = 前一页码 $\times$ 100



#### 分析 Json

双击截图中的  search-index ，可以看到格式化的 Json，命名为 info。将每条结果命名为 case。这里主要提取的变量及对应的 Json 路径为：

- 查询结果总数 `info['hits']['total']['value']`
- 对于每条结果：
  - 文件 id  `case['_id']`
  - CIK
    - Shareholder Letter 接受实体  `case['_source']['ciks'][0]`
    - Shareholder Letter 发出实体  `case['_source']['ciks'][1]`
  - 文件序号  `case['_source']['file_num']`
  - 实体名称
    - Shareholder Letter 接受实体  `case['_source']['display_names'][0]`
    - Shareholder Letter 发出实体  `case['_source']['display_names'][1]`
  - 文件日期  `case['_source']['file_date']`
  - Adsh  `case['_source']['adsh']`

![image-20210610141015069](http://ww1.sinaimg.cn/large/008iTKOogy1grdgbkg6cej312g0tc41i.jpg)



#### 爬取文件列表代码

```python
import time
import json
import csv
import math
import requests
from tqdm import tqdm

headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "en-US,en;q=0.5",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
           }

def postpage(year, page):
    come = (page-1)*100
    post = "{\"dateRange\":\"custom\",\"category\":\"custom\",\"startdt\":\"%s-01-01\",\"enddt\":\"%s-12-31\",\"forms\":[\"SC 13D\"],\"page\":\"%s\",\"from\":%s}"%(year,year,page,come)
    return(post)

def getinfo(year, page):    
    with open("edgarcookies.txt", "r")as f:
        cookies = f.read()
        cookies = json.loads(cookies)
        session = requests.session()

        url = "https://efts.sec.gov/LATEST/search-index"
        data = session.post(url,  headers=headers, cookies=cookies, data=postpage(year, page))
        time.sleep(1)

        info = json.loads(data.text)

        totalnum = info['hits']['total']['value']

        for case in info['hits']['hits']:
            with open('edgar13D_check.csv','a') as g:
                h = csv.writer(g)

                id = case['_id']
                try:
                    cik0 = case['_source']['ciks'][0]
                    cik1 = case['_source']['ciks'][1]
                except:
                    cik0 = ""
                    cik1 = ""
                root_form = case['_source']['root_form']
                file_num = case['_source']['file_num']
                try:
                    display_names_0 = case['_source']['display_names'][0]
                    display_names_1 = case['_source']['display_names'][1]
                except:
                    display_names_0 = ""
                    display_names_1 = ""
                file_date = case['_source']['file_date']
                adsh = case['_source']['adsh']

                out = [id,cik0,cik1,root_form, file_num, display_names_0, display_names_1,file_date,adsh]
                h.writerow(out)

        return(totalnum)

for year in range(2001, 2022):
    totalnum = getinfo(year,1)
    print(totalnum)
    pagenum = math.ceil(totalnum/100)+1
    print("%s %s"%(year,pagenum))
    for page in tqdm(range(2,pagenum)):
        getinfo(year,page)
```



#### 列表爬取结果

![image-20210610142043228](http://ww1.sinaimg.cn/large/008iTKOogy1grdgbt1g22j311a0mw7bz.jpg)



#### 分析 EDGAR 文件地址

先来分析 EDGAR 文件地址的结构，一个典型的 EDGAR 文件地址

> https://www.sec.gov/Archives/edgar/data/0001762728/000092189521001513/sc13da412475002_05272021.htm

主要包含三个部分

- “https://www.sec.gov/Archives/edgar/data/”

- 接受实体 CIK [上表列2]

- id (e.g., 0001214659-21-005763:p519211sc13da7.htm) [上表列1] 中的 ":" 换成  "/"， "-" 换成  "" 

  

#### 爬取对应 EDGAR 文件代码

```python
import os
import pandas as pd
import json
import csv
from tqdm import tqdm
import requests

df = pd.read_csv("edgar13d09-16.csv",header=0)

headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "en-US,en;q=0.5",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
           }

with open("edgarcookies.txt", "r")as f:
	cookies = f.read()
	cookies = json.loads(cookies)
	session = requests.session()


for row in tqdm(df.iterrows()):
	url = row[1][0].replace(":","/").replace("-","")
	cik = row[1][1]
	filedate = row[1][7].replace('/','-')
	filename = "%s_%s"%(filedate,row[1][0])
	href=  "https://www.sec.gov/Archives/edgar/data/%s/%s"%(cik,url)
	data = session.get(href,  headers=headers, cookies=cookies)
	with open("/Users/mengjiexu/Dropbox/edgar13d/%s"%filename,'wb') as g:
		g.write(data.content)
```

