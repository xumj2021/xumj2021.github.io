---

title:       "Connect to the WRDS Cloud via Python"
subtitle:    ""
description: "Make your WRDS data extraction replicable"
date:        2021-10-12
author:      "Mengjie Xu"
toc:         true
image:    "https://assets.bbhub.io/company/sites/51/2020/11/BBG_Barclays_sphere_680x455.jpg"
tags:        ["WRDS", "SSH"]
categories:  ["Data" ]


---



## Motivation

The WRDS-SAS Studio cloud seems to be suspended soon. As a big fan of this cloud platform, I have to find something alternative to make my data extraction from WRDS replicable. Compiled from a series of WRDS guidances (you can find them in the reference), this blog will introduce how to connect WRDS cloud via Python. Though providing no additional information, this blog helps you quickly establish your python-wrds workflow without checking various manuals.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-12%20%E4%B8%8A%E5%8D%8810.46.04.png" width=500 height=200>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 1: Suspension of WRDS-SAS Studio</div>
</center>



## Connect to WRDS using SSH

### Mac OS

MacOS computers come with a utility called *Terminal* that has SSH functionality built-in that can be used to connect to the WRDS Cloud. You can initiate an SSH connection to the WRDS Cloud as follows:

- Type `ssh wrdsusername@wrds-cloud.wharton.upenn.edu` where *wrdsusername* is your WRDS username: the same username you use to log onto the WRDS website.
- When prompted, enter your WRDS password.
- Once you have connected to the WRDS Cloud, you will be given a *prompt* -- which indicates that the server is ready for your commands.
- You can disconnect from the WRDS Cloud at anytime by typing `logout` or using the key combination CTL-D.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-12%20%E4%B8%8A%E5%8D%8811.06.00.png" width=500 height=500>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 2: Bloomberg Add-in in Excel</div>
</center>


### Windows

If you are on Windows, you will need to download and install SSH client software (e.g., PuTTY, WinSCP) to your computer. 

Once you have downloaded and installed one of the above, you can initiate an SSH connection to the WRDS Cloud. Suppose you use PuTTY and want **to configure PuTTY for SSH:**

1. In **Host Name**, enter `wrds-cloud.wharton.upenn.edu`
2. In **Port** (skip if there is no Port field), enter `22`
3. When prompted, enter your WRDS username.
4. When prompted, enter your WRDS password.



## Open IPython in the Cloud

Interactive Python jobs allow you to run code in serial, and receive a response to each command as you enter it. To run interactive Python jobs, you will need to schedule an interactive job with the WRDS Cloud Grid Engine by entering `qrsh`  and then enter `ipython3` to enter an interactive python enviornment, which is exactly what you get in `Jupyter`. Don't forget to insert `pip install wrds` before you connect to the WRDS library list.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-12%20%E4%B8%8A%E5%8D%8811.16.03.png" width=800 height=300>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 3: Interactive Python Job</div>
</center>




## Initiating a WRDS connection in Python

First, as with every Python program that intends to connect to WRDS, you must import the **wrds** module. Then you can make the connection and set up a **pgpass** file.

```python
In [4]: db = wrds.Connection()
Enter your WRDS username [xumj2019]:xumj2019
Enter your password:
WRDS recommends setting up a .pgpass file.
Create .pgpass file now [y/n]?: y
Created .pgpass file successfully.
Loading library list...
Done
```



### Explore WRDS Libraries and Tables

You can analyze the structure of the data through its metadata using the **wrds** module, as outlined in the following steps:

- List all available *libraries* at WRDS using `list_libraries()`

- Select a library to work with, and list all available *datasets* within that library using `list_tables()`

- Select a dataset, and list all available *variables* (column headers) within that dataset using `describe_table()`

```python
In [5]: db.list_libraries()
Out[5]: 
['aha',
 'aha_sample',
 'ahasamp',
 'audit',
 'auditsmp',
 'auditsmp_all',
 'bank',
 'blab',
 'block',
 'block_all',
 'boardex',
 'boardex_trial',
 'boardsmp',
 'bvd',
	...]
In [7]: db.list_tables(library='taqmsec')
Out[7]: 
['cqm_20030910',
 'cqm_20030911',
 'cqm_20030912',
 'cqm_20030915',
 'cqm_20030916',
 'cqm_20030917',
 'cqm_20030918',
 'cqm_20030919',
 'cqm_20030922',
 'cqm_20030923',
 'cqm_20030924',
 'cqm_20030925',
 'cqm_20030926',
 'cqm_20030929',
 'cqm_20070829',
 	...]
In [9]: db.describe_table(library='taqmsec', table='cqm_20070822')
The row count will return 0 due to the structure of TAQ
There was a problem with retrievingthe row count: 'NoneType' object is not subscriptable
Approximately 0 rows in taqmsec.cqm_20070822.
Out[9]: 
           name  nullable         type
0          date      True         DATE
1        time_m      True         TIME
2            ex      True   VARCHAR(1)
3      sym_root      True   VARCHAR(6)
4    sym_suffix      True  VARCHAR(10)
5           bid      True      NUMERIC
6        bidsiz      True      NUMERIC
7           ask      True      NUMERIC
8        asksiz      True      NUMERIC
9       qu_cond      True   VARCHAR(1)
10        bidex      True   VARCHAR(1)
11        askex      True   VARCHAR(1)
12    qu_seqnum      True      NUMERIC
13   natbbo_ind      True   VARCHAR(1)
14  nasdbbo_ind      True   VARCHAR(1)
15    qu_cancel      True   VARCHAR(1)
16    qu_source      True   VARCHAR(1)
```



### Submit Queries

Now that you know how to query the metadata and understand the structure of the data, you are ready to query WRDS data directly. The **wrds** module provides several methods that are useful in gathering data:

- `get_table()` - fetches data by matching library and dataset, with the ability to filter using different parameters. This is the easiest method of accessing data.
- `raw_sql()` - executes a SQL query against the specified library and dataset, allowing for highly-granular data queries.
- `get_row_count()` - returns the number of rows in a given dataset.

For parameters, and further explanation of each, use the built-in help: e.g., `help(db.get_table)`.

Here are some examples.

```python
In [10]: data = db.get_table(library='djones', table='djdaily', columns=['date', 'dji'], obs=10)

In [11]: data
Out[11]: 
         date    dji
0  1896-05-26  40.94
1  1896-05-27  40.58
2  1896-05-28  40.20
3  1896-05-29  40.63
4  1896-06-01  40.60
5  1896-06-02  40.04
6  1896-06-03  39.77
7  1896-06-04  39.94
8  1896-06-05  40.32
9  1896-06-08  39.81

In [12]: parm = {'tickers': ('0015B', '0030B', '0032A', '0033A', '0038A')}

In [13]: data = db.raw_sql('SELECT datadate,gvkey,cusip FROM comp.funda WHERE tic in %(tickers)s', params=parm)
    ...: 

In [14]: data
Out[14]: 
       datadate   gvkey      cusip
0    1982-10-31  002484  121579932
1    1983-10-31  002484  121579932
2    1984-10-31  002484  121579932
3    1985-10-31  002484  121579932
4    1986-10-31  002484  121579932
..          ...     ...        ...
208  2009-12-31  179519  61847Z002
209  2010-12-31  179519  61847Z002
210  2010-12-31  179519  61847Z002
211  2011-12-31  179519  61847Z002
212  2011-12-31  179519  61847Z002

[213 rows x 3 columns]

In [15]: data = db.get_row_count('djones', 'djdaily')

In [16]: data
Out[16]: 27933

In [17]: db.raw_sql("select a.gvkey, a.datadate, a.tic, a.conm, a.at, a.lt, b.prccm, b.cshoq from comp.funda a join comp.secm b on 
    ...: a.gvkey = b.gvkey and a.datadate = b.datadate where a.tic = 'IBM' and a.datafmt = 'STD' and a.consol = 'C' and a.indfmt = 
    ...: 'INDL'")
    ...: 
Out[17]: 
     gvkey    datadate  tic                         conm          at          lt       prccm     cshoq
0   006066  1962-12-31  IBM  INTL BUSINESS MACHINES CORP    2112.301     731.700  389.999567       NaN
1   006066  1963-12-31  IBM  INTL BUSINESS MACHINES CORP    2373.857     782.119  506.999353       NaN
2   006066  1964-12-31  IBM  INTL BUSINESS MACHINES CORP    3309.152    1055.072  409.499496       NaN
3   006066  1965-12-31  IBM  INTL BUSINESS MACHINES CORP    3744.917    1166.771  498.999146       NaN
4   006066  1966-12-31  IBM  INTL BUSINESS MACHINES CORP    4660.777    1338.149  371.499662       NaN
5   006066  1967-12-31  IBM  INTL BUSINESS MACHINES CORP    5598.668    1767.067  626.999512       NaN
6   006066  1968-12-31  IBM  INTL BUSINESS MACHINES CORP    6743.430    2174.291  314.999847       NaN
7   006066  1969-12-31  IBM  INTL BUSINESS MACHINES CORP    7389.957    2112.967  364.499359   113.717
8   006066  1970-12-31  IBM  INTL BUSINESS MACHINES CORP    8539.047    2591.909  317.749634   114.587
9   006066  1971-12-31  IBM  INTL BUSINESS MACHINES CORP    9576.219    2933.837  336.499634   115.534
10  006066  1972-12-31  IBM  INTL BUSINESS MACHINES CORP   10792.398    3226.508  401.999512   116.399
11  006066  1973-12-31  IBM  INTL BUSINESS MACHINES CORP   12289.500    3477.465  246.749878   146.713
12  006066  1974-12-31  IBM  INTL BUSINESS MACHINES CORP   14027.098    3916.766  167.999878   148.259
13  006066  1975-12-31  IBM  INTL BUSINESS MACHINES CORP   15530.504    4114.705  224.249878   149.845
14  006066  1976-12-31  IBM  INTL BUSINESS MACHINES CORP   17723.203    4974.035  279.124756   150.695
15  006066  1977-12-31  IBM  INTL BUSINESS MACHINES CORP   18978.402    6359.965  273.499756   147.471
16  006066  1978-12-31  IBM  INTL BUSINESS MACHINES CORP   20771.406    7277.759  298.499878   145.810
17  006066  1979-12-31  IBM  INTL BUSINESS MACHINES CORP   24530.004    9568.734   64.374969   583.595
18  006066  1980-12-31  IBM  INTL BUSINESS MACHINES CORP   26703.008   10250.000   67.874939   583.807
19  006066  1981-12-31  IBM  INTL BUSINESS MACHINES CORP   29586.008   11425.000   56.874969   592.294
20  006066  1982-12-31  IBM  INTL BUSINESS MACHINES CORP   32541.008   12581.000   96.250000   602.406
21  006066  1983-12-31  IBM  INTL BUSINESS MACHINES CORP   37243.008   14024.000  122.000000   610.725
22  006066  1984-12-31  IBM  INTL BUSINESS MACHINES CORP   42808.012   16319.000  123.125000   612.685
23  006066  1985-12-31  IBM  INTL BUSINESS MACHINES CORP   52634.016   20644.000  155.500000   615.418
24  006066  1986-12-31  IBM  INTL BUSINESS MACHINES CORP   57814.016   23440.000  120.000000   605.923
25  006066  1987-12-31  IBM  INTL BUSINESS MACHINES CORP   63688.000   25425.000  115.500000   597.052
26  006066  1988-12-31  IBM  INTL BUSINESS MACHINES CORP   73037.000   33528.000  121.875000   589.741
27  006066  1989-12-31  IBM  INTL BUSINESS MACHINES CORP   77734.000   39225.000   94.125000   574.700
28  006066  1990-12-31  IBM  INTL BUSINESS MACHINES CORP   87568.000   44736.000  113.000000   571.391
29  006066  1991-12-31  IBM  INTL BUSINESS MACHINES CORP   92473.000   55467.000   89.000000   571.018
30  006066  1992-12-31  IBM  INTL BUSINESS MACHINES CORP   86705.000   59081.000   50.375000   571.436
31  006066  1993-12-31  IBM  INTL BUSINESS MACHINES CORP   81113.000   61375.000   56.500000   581.386
32  006066  1994-12-31  IBM  INTL BUSINESS MACHINES CORP   81091.000   57678.000   73.500000   587.710
33  006066  1995-12-31  IBM  INTL BUSINESS MACHINES CORP   80292.000   57869.000   91.375000   547.774
34  006066  1996-12-31  IBM  INTL BUSINESS MACHINES CORP   81132.000   59504.000  151.500000   507.981
35  006066  1997-12-31  IBM  INTL BUSINESS MACHINES CORP   81499.000   61683.000  104.625000   958.091
36  006066  1998-12-31  IBM  INTL BUSINESS MACHINES CORP   86100.000   66667.000  184.375000   915.907
37  006066  1999-12-31  IBM  INTL BUSINESS MACHINES CORP   87495.000   66984.000  107.875000  1784.216
38  006066  2000-12-31  IBM  INTL BUSINESS MACHINES CORP   88349.000   67725.000   85.000000  1742.900
39  006066  2001-12-31  IBM  INTL BUSINESS MACHINES CORP   88313.000   64699.000  120.960000  1723.194
40  006066  2002-12-31  IBM  INTL BUSINESS MACHINES CORP   96484.000   73702.000   77.500000  1722.367
41  006066  2003-12-31  IBM  INTL BUSINESS MACHINES CORP  104457.000   76593.000   92.680000  1694.509
42  006066  2004-12-31  IBM  INTL BUSINESS MACHINES CORP  109183.000   79436.000   98.580000  1645.592
43  006066  2005-12-31  IBM  INTL BUSINESS MACHINES CORP  105748.000   72650.000   82.200000  1573.980
44  006066  2006-12-31  IBM  INTL BUSINESS MACHINES CORP  103234.000   74728.000   97.150000  1506.483
45  006066  2007-12-31  IBM  INTL BUSINESS MACHINES CORP  120431.000   91961.000  108.100000  1385.234
46  006066  2008-12-31  IBM  INTL BUSINESS MACHINES CORP  109524.000   96059.000   84.160000  1339.096
47  006066  2009-12-31  IBM  INTL BUSINESS MACHINES CORP  109022.000   86267.000  130.900000  1305.337
48  006066  2010-12-31  IBM  INTL BUSINESS MACHINES CORP  113452.000   90280.000  146.760000  1227.993
49  006066  2011-12-31  IBM  INTL BUSINESS MACHINES CORP  116433.000   96197.000  183.880000  1163.183
50  006066  2012-12-31  IBM  INTL BUSINESS MACHINES CORP  119213.000  100229.000  191.550000  1117.368
51  006066  2013-12-31  IBM  INTL BUSINESS MACHINES CORP  126223.000  103294.000  187.570000  1054.391
52  006066  2014-12-31  IBM  INTL BUSINESS MACHINES CORP  117532.000  105518.000  160.440000   990.524
53  006066  2015-12-31  IBM  INTL BUSINESS MACHINES CORP  110495.000   96071.000  137.620000   965.729
54  006066  2016-12-31  IBM  INTL BUSINESS MACHINES CORP  117470.000   99078.000  165.990000   945.867
55  006066  2017-12-31  IBM  INTL BUSINESS MACHINES CORP  125356.000  107631.000  153.420000   922.179
56  006066  2018-12-31  IBM  INTL BUSINESS MACHINES CORP  123382.000  106453.000  113.670000   892.479
57  006066  2019-12-31  IBM  INTL BUSINESS MACHINES CORP  152186.000  131201.000  134.040000   887.110
58  006066  2020-12-31  IBM  INTL BUSINESS MACHINES CORP  155971.000  135244.000  125.880000   892.653
In [42]: data=db.raw_sql("SELECT * FROM taqmsec.cqm_20170829 WHERE sym_root = 'A
    ...: APL' AND time_m>='04:00:00.084000' and time_m <= '04:01:00.084000'")

In [43]: data
Out[43]: 
          date           time_m ex  ...  finra_adf_mquo_ind  sym_root  sym_suffix
0   2017-08-29  04:00:00.084000  Q  ...                None      AAPL        None
1   2017-08-29  04:00:00.084000  Q  ...                None      AAPL        None
2   2017-08-29  04:00:00.203000  P  ...                None      AAPL        None
3   2017-08-29  04:00:00.203000  P  ...                None      AAPL        None
4   2017-08-29  04:00:00.203000  P  ...                None      AAPL        None
..         ...              ... ..  ...                 ...       ...         ...
89  2017-08-29  04:00:57.213000  P  ...                None      AAPL        None
90  2017-08-29  04:00:57.288000  P  ...                None      AAPL        None
91  2017-08-29  04:00:57.293000  P  ...                None      AAPL        None
92  2017-08-29  04:00:59.543000  P  ...                None      AAPL        None
93  2017-08-29  04:00:59.543000  P  ...                None      AAPL        None

[94 rows x 24 columns]
In [44]: data.to_csv("test.csv")
```



## Transfer Data through Dropbox

Insert `ls` in your ssh command line, you will find the files you've saved in your wrds cloud. Apparently, how to transfer files with the wrds cloud is an issue you cannot sidestep. After tests, I personally found linking WRDS with Dropbox is the most efficient way to do this job.

```python
[xumj2019@wrds-sas7-w ~]$ ls
autoexec.sas      testaq.sas                 WRDS_batch_ticker_ctm.sas
evt_taqinput.txt  test.csv                   WRDS_batch_ticker_ct.sas
myProgram.csv     WRDS_batch_ticker_cqm.sas
```

WRDS provides the `dbxcli` command on the WRDS cloud login nodes to transfer data directly between WRDS and your dropbox shares. `dbxcli` is a simple, ftp like transfer client; it only transfers files between dropbox and clients.

To do this, you need:

- Login to the WRDS cloud via ssh
  - If you are in the IPython enviornment, you need to insert `quit` to quit IPython, and then `logout` to exit the Interactive Jobs

- Run the `dbxcli account` command.

  ```PYTHON
  [xumj2019@wrds-cloud-login2-w ~]$ dbxcli account
  1. Go to https://www.dropbox.com/1/oauth2/authorize?client_id=07o23gulcj8qi69&response_type=code&state=state
  2. Click "Allow" (you might have to log in first).
  3. Copy the authorization code.
  Enter the authorization code here: NMdc-gHdd7AAAAAAAAAEL3CRL_GpJce0RQ
  Logged in as xx xx <xx@xx.com>
  
  Account Id:        dbid:AAB4yqaueMTEfU4-8
  Account Type:      pro
  Locale:            en
  Referral Link:     https://www.dropbox.com/referrals/AABnCSjxOA?src=app9-934508
  Profile Photo Url: https://dl-web.dropbox.com/account_photo/get/dbaphid%3AAAAgMQf5azIHq65no?size=128x128&vers=1561290642421
  Paired Account:    false
  ```

- Follow the instructions the command gives and paste in the authorization code.

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-12%20%E4%B8%8B%E5%8D%884.42.14.png" width=500 height=300>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 4: Connect WRDS Cloud to Dropbox</div>
  </center>

- If you successfully logged in the command should print your dropbox account information. You may run `dbxcli account` again to confirm if your account is connected, if it prints your account information it is connected.

## References

- [PYTHON: On the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/python-wrds-cloud/)
- [Submitting Python Jobs](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/submitting-python-programs/)
- [Login to the WRDS cloud via ssh](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/using-ssh-connect-wrds-cloud/) 
- [Interactive Jobs on the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/running-jobs/interactive-jobs-wrds-cloud/)
- [Querying WRDS Data using Python](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/querying-wrds-data-python/)
- [Example Python Data Workflow](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/python-example-data-workflow/)
- [Storing Your Data on the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/storing-your-data-wrds-cloud/)
- [Transfering Data with Dropbox](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/transfering-data-with-dropbox/)

