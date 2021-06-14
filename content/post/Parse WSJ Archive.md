---

title:       "Obtain All Archive Data From Wall Street Journal"
subtitle:    ""
description: "Crawling WSJ Archive"
date:        2021-06-13
author:      ""
image:       "static/wsj.jpeg"
tags:        ["WSJ", "Financial News"]
categories:  ["Tech" ]

---





从读论文和写论文的体验来看，传闻证据 (anecdotes) 对论文能不能给人可靠的第一印象有决定性作用。传闻证据到位了，就不会有人追着问一些澄清性问题 (clarification questions)，后面论证研究题目的重要性时也会顺利很多 (why care)，此外，很多时候传闻证据对作者本人更好地了解研究背景 (institutional background) 并提出合情合理的研究设计也有很大的帮助作用[^1]。

据我所知，华尔街日报 (Wall Street Journal) 给很多顶刊论文提供了灵感。比如 [Zhu (2019 RFS)](https://academic.oup.com/rfs/article/32/5/2021/5427775) 与 [用停车场数据预测零售公司业绩的报道非常相关 (2014.11.20 WSJ)](https://www.wsj.com/articles/startups-mine-market-moving-data-from-fields-parking-lotseven-shadows-1416502993)， [一篇关于对冲基金经理与大数据的报道 (2013.12.18 WSJ)](https://www.wsj.com/articles/SB10001424052702303497804579240182187225264) 则提出了 [Katona et al. (2018 WP, MS R&R)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3222741)  和 [Mukherjee et al. (2021 JFE)](https://www.sciencedirect.com/science/article/pii/S0304405X21000921) 的主要论点。

所以我最近写论文的时候爬了华尔街日报的所有历史数据，源网址是 [WSJ Archives](https://www.wsj.com/news/archive/years)，事实证明这个工作在我最近的论文展示中起到了相当正面的作用[^2]。



#### 1. 获取 Cookies

按照惯例，还是先获取 Cookies。首先登陆，登陆后等待大概 20 秒左右会跳出一个小框，要求接受 cookies，需要点击 `YES, I AGREE`， 经过这步操作的 Cookies 才能顺利获取文章列表或文章内容，否则会被网站识别为爬虫。

另外， Cookies 有失效时间 (expiry time)，最好每次爬之前都更新下 Cookies。

```python
from selenium import webdriver
import time
import json

option = webdriver.FirefoxOptions()
option.add_argument('-headless')
driver = webdriver.Firefox(executable_path='/Users/mengjiexu/Dropbox/Pythoncodes/Bleier/geckodriver')

# 填入 WSJ 账户信息
email = 'username'
pw = 'password'
  
def login(email, pw):
    driver.get(
        "https://sso.accounts.dowjones.com/login?")
    # 为了不透露个人信息，需要读者自己粘贴登陆界面的 url
    time.sleep(5)
    driver.find_element_by_xpath("//div/input[@name = 'username']").send_keys(email)
    driver.find_element_by_xpath("//div/input[@name = 'password']").send_keys(pw)
    driver.find_element_by_xpath("//div/button[@type = 'submit']").click()

# 登陆
login(email, pw)

time.sleep(20)

# 切换到跳出的小框
driver.switch_to_frame("sp_message_iframe_490357")
# 点击接受收集 Cookies 
driver.find_element_by_xpath("//button[@title='YES, I AGREE']").click()

time.sleep(5)

# 将 Cookies 写入文件
orcookies = driver.get_cookies()
print(orcookies)
cookies = {}
for item in orcookies:
    cookies[item['name']] = item['value']
with open("wsjcookies.txt", "w") as f:
    f.write(json.dumps(cookies))
```



#### 2. 获取文章列表

##### 2.1 网页分析

WSJ 每日文章列表 url 的命名方式十分简单，由以下两部分组成：

- https://www.wsj.com/news/archive/
- 年/月/日

所以在指定时间范围内遍历每一天即可得到每一天的文章列表。不过我爬的时候顺手爬了所有的日期列表，所以代码中直接遍历了日期列表。

> WSJ Daylist: 链接: https://pan.baidu.com/s/1kPYlot5lmYtQwWlHxA6OpQ  密码: 0b44

以 2021 年 6 月 10 日的文章列表为例 (如下图)，对于每一篇文章，主要关注四个变量：

- 文章所属板块 - 黄色框
- 文章标题 - 红色框
- 文章链接 - 绿色框
- 文章日期 - 前定

很多日期的文章列表都不止一页，所以需要：

- 判断翻页条件：详见代码中 `pagenation(page)` 函数
- 如果满足翻页条件，进行翻页：`newdaylink = daylink + "?page=%s"%pagenum`

![截屏2021-06-10 下午3.33.56](http://ww1.sinaimg.cn/large/008iTKOogy1grebju21whj31ew0wqam6.jpg)



##### 2.2 代码

```python
import time
from lxml import etree
import csv
import re
from tqdm import tqdm
import requests
import json
import pandas as pd
import csv
import unicodedata
from string import punctuation

f = open('wsjdaylist.txt', 'r')

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0',
"content-type": "application/json; charset=UTF-8",
"Connection": "keep-alive"
}


def parsearticle(date, daylink):
    with open("wsjcookies.txt", "r")as f:
        cookies = f.read()
        cookies = json.loads(cookies)
    session = requests.session()
    url = "https://www.wsj.com" + daylink
    data = session.get(url, headers=headers, cookies = cookies)

    time.sleep(1)
    page = etree.HTML(data.content)

    href = page.xpath("//h2[@class='WSJTheme--headline--unZqjb45 reset WSJTheme--heading-3--2z_phq5h typography--serif-display--ZXeuhS5E ']/a/@href")

    sector = page.xpath("//h2[@class='WSJTheme--headline--unZqjb45 reset WSJTheme--heading-3--2z_phq5h typography--serif-display--ZXeuhS5E ']/parent::div[1]/parent::div[1]/preceding-sibling::div[1]//text()[1]")
    module = [unicodedata.normalize('NFD', i).encode('ascii', 'ignore').decode("utf-8").replace("\n"," ").replace('\t',"") for i in sector if len(i)>1]
    
    article = page.xpath("//h2[@class='WSJTheme--headline--unZqjb45 reset WSJTheme--heading-3--2z_phq5h typography--serif-display--ZXeuhS5E ']/a/text()")
    article = [unicodedata.normalize('NFD', i).encode('ascii', 'ignore').decode("utf-8").replace("\n"," ").replace('\t',"") for i in article]
    
    with open("wsjarticlelist_test.csv",'a') as h:
        k = csv.writer(h)
        for i in range(len(href)):
            k.writerow([article[i], module[i], href[i], date])

    return(page)

def pagenation(page):
    next_page = page.xpath("//span[contains(text(), 'Next Page')]")
    return(next_page)

for line in f:
    daylink = line.strip()
    date = daylink.split("/archive/")[-1]
    page = parsearticle(date, daylink)
    next_page = pagenation(page)
    pagenum = 1
    while next_page:
        pagenum +=1
        print(pagenum)
        newdaylink = daylink + "?page=%s"%pagenum
        page = parsearticle(date, newdaylink)
        next_page = pagenation(page)
        time.sleep(1)
```



##### 2.3 文章列表

![image-20210611091513883](http://ww1.sinaimg.cn/large/008iTKOogy1greclpq58nj31fu0va14z.jpg)



##### 2.4 文章年份分布

| Year  | ArticleNum |
| :---: | :--------: |
| 1997  |    171     |
| 1998  |   45953    |
| 1999  |   48813    |
| 2000  |   51485    |
| 2001  |   46691    |
| 2002  |   42997    |
| 2003  |   38974    |
| 2004  |   39071    |
| 2005  |   40219    |
| 2006  |   41779    |
| 2007  |   44754    |
| 2008  |   51897    |
| 2009  |   54993    |
| 2010  |   66245    |
| 2011  |   70842    |
| 2012  |   66032    |
| 2013  |   64420    |
| 2014  |   71768    |
| 2015  |   66051    |
| 2016  |   74229    |
| 2017  |   59907    |
| 2018  |   49528    |
| 2019  |   36292    |
| 2020  |   35819    |
| 2021  |   12011    |
| Total |  1220941   |



##### 2.5 文章主题分布

排除空白主题，1997-2021年共有 5822 个不同的主题。这里列出使用次数超出 10,000 的主题。

|            Sector             | ArticleNum |
| :---------------------------: | :--------: |
|           Business            |   60119    |
|            Markets            |   34663    |
|             U.S.              |   23402    |
|      Heard on the Street      |   23340    |
|      Major Business News      |   22598    |
|            Letters            |   21531    |
|           Politics            |   20991    |
|          Tech Center          |   18511    |
|           Earnings            |   18178    |
|          Technology           |   17346    |
|      U.S. Business News       |   17109    |
|            Europe             |   15134    |
|            Economy            |   14432    |
|            Photos             |   14290    |
|       Review & Outlook        |   13759    |
| Business and Finance - Europe |   13530    |
|          Commentary           |   13428    |
|            Health             |   12979    |
|  Business and Finance - Asia  |   12723    |
|             Asia              |   11163    |
|           Bookshelf           |   11128    |
|             World             |   10833    |
|       Media & Marketing       |   10629    |
|      Asian Business News      |   10428    |
|          Commodities          |   10159    |
|             Tech              |   10153    |

主题中包含中国的文章有

|               Sector               | ArticleNum |
| :--------------------------------: | :--------: |
|             China 2008             |     1      |
|             China 2009             |     1      |
|           Snow in China            |     1      |
|            China Stocks            |     1      |
|     China's Changing Workforce     |     1      |
|        China's Money Trail         |     2      |
|        China's Rising Risks        |     4      |
| China: The People's Republic at 50 |     12     |
|              My China              |     12     |
|      China Trade Breakthrough      |     19     |
|           China's World            |     79     |
|           China Circuit            |     86     |
|            Chinas World            |    127     |
|             China News             |    1101    |
|               China                |    1875    |
|               Total                |    3322    |



#### 3. 爬取文章内容

##### 3.1 分析网页

从网页中获取所有文字信息并不难，但是 WSJ 文章会在文章中插入超链接，如果不做处理的话，爬下来的文字会有很多不符合阅读习惯的换行。我做的处理有：

- 使用函数 `translist(infolist)` 筛掉不必要的空格和换行
- 没有采用直接获取符合条件 html element 下的所有文字的方法，而是对每个 element 进行遍历进行更加精细的筛选。这样做的速度稍微慢一点，但是基本上能呈现比较好的视觉呈现效果

![image-20210611095037381](http://ww1.sinaimg.cn/large/008iTKOogy1gredmij3mkj31e80woqiq.jpg)

##### 3.2 爬取文章代码

```python
import time
from lxml import etree
import csv
import re
from tqdm import tqdm
import requests
import json
import pandas as pd
import csv
import unicodedata
from string import punctuation

df = pd.read_excel("/Users/mengjiexu/Dropbox/wsj0512/wsj0513.xlsx",header=0)

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0',
"content-type": "application/json; charset=UTF-8",
"Connection": "keep-alive"
}

def translist(infolist):
    out = list(filter(lambda s: s and (type(s) != str or len(s.strip()) > 0), [i.strip() for i in infolist]))
    return(out)

def parsearticle(title, date, articlelink):
    with open("wsjcookies.txt", "r")as f:
        cookies = f.read()
        cookies = json.loads(cookies)
    session = requests.session()
    data = session.get(articlelink, headers=headers, cookies = cookies)
    time.sleep(1)
    
    page = etree.HTML(data.content)

    arcontent = title + '\n\n' + date +'\n\n'

    content = page.xpath("//div[@class='article-content  ']//p")
    for element in content:
        subelement = etree.tostring(element).decode()
        subpage = etree.HTML(subelement)
        tree = subpage.xpath('//text()')
        line = ''.join(translist(tree)).replace('\n','').replace('\t','').replace('  ','').strip()+'\n\n'
        arcontent += line

    return(arcontent)


for row in tqdm(df.iterrows()):
    title = row[1][0].replace('/','-')
    articlelink = row[1][2]
    date = row[1][3].replace('/','-')
    arcontent = parsearticle(title, date, articlelink)
    with open("/Users/mengjiexu/Dropbox/articles/%s_%s.txt"%(date,title),'w') as g:
        g.write(''.join(arcontent))
```



##### 3.3 爬取文章样例

![image-20210611095918552](http://ww1.sinaimg.cn/large/008iTKOogy1greeas4m6cj31j410sqdm.jpg)



#### 4. 翻译

英语阅读速度比较慢的朋友可以调用 [百度 API](https://api.fanyi.baidu.com/api/trans/product/desktop?req=detail)  对文章进行翻译，这样可以一目十行快速提取大量文章信息。为了提高翻译速度，最好整篇文章作为一个文字整体翻译。



##### 4.1 翻译文章代码

```python
import os
import requests
import random
import json
from hashlib import md5
from tqdm import tqdm

file_list = os.listdir("/Users/mengjiexu/Dropbox/articles/")

# Set your own appid/appkey.
appid = 'xxx'
appkey = 'xxx'

# For list of language codes, please refer to `https://api.fanyi.baidu.com/doc/21`
from_lang = 'en'
to_lang =  'zh'

endpoint = 'http://api.fanyi.baidu.com'
path = '/api/trans/vip/translate'
url = endpoint + path

# Generate salt and sign
def make_md5(s, encoding='utf-8'):
    return md5(s.encode(encoding)).hexdigest()

salt = random.randint(32768, 65536)
headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def trans(query):

	sign = make_md5(appid + query + str(salt) + appkey)

	# Build request
	payload = {'appid': appid, 'q': query, 'from': from_lang, 'to': to_lang, 'salt': salt, 'sign': sign}

	# Send request
	r = requests.post(url, params=payload, headers=headers)
	result = r.json()

	# Show response
	rusult = json.dumps(result, indent=4, ensure_ascii=False)

	return(result["trans_result"][0]["dst"])

for file in tqdm(file_list):
	content =open("/Users/mengjiexu/Dropbox/articles/%s"%file, 'r').read()
	print(trans(content.strip()))
```



##### 4.2 翻译文章样例

![image-20210611100138437](http://ww1.sinaimg.cn/large/008iTKOogy1gredy2v7mxj31ki1181kx.jpg)





[^1]: 写上对应的英语表达是确保读者理解的意思和我表达的意思不出现偏差而做的一个双重解释。
[^2]: 获取 WSJ Archive 信息需要购买 WSJ 账号，本文只做交流学习使用，不建议使用本文内容获利。



#### 参考文献

- Zhu, Christina. 2019. “Big Data as a Governance Mechanism.” *The Review of Financial Studies* 32 (5): 2021–61.[-PDF-](https://doi.org/10.1093/rfs/hhy081).

- Katona, Zsolt, Marcus Painter, Panos N. Patatoukas, and Jean Zeng. 2018. “On the Capital Market Consequences of Alternative Data: Evidence from Outer Space.” SSRN Scholarly Paper ID 3222741. Rochester, NY: Social Science Research Network. [-PDF-](https://doi.org/10.2139/ssrn.3222741).

- Mukherjee, Abhiroop, George Panayotov, and Janghoon Shon. 2021. “Eye in the Sky: Private Satellites and Government Macro Data.” *Journal of Financial Economics*, March. [-PDF-](https://doi.org/10.1016/j.jfineco.2021.03.002).