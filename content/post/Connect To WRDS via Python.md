---

title:       "Exploit WRDS Cloud via Python"
subtitle:    ""
description: "Make your WRDS data extraction and processing replicable"
date:        2021-10-12
author:      "Mengjie Xu"
toc:         true
image:    "https://assets.bbhub.io/company/sites/51/2020/11/BBG_Barclays_sphere_680x455.jpg"
tags:        ["WRDS", "SSH"]
categories:  ["Data" ]


---



## Motivation

The WRDS-SAS Studio seems to be suspended soon. As a big fan of this cloud platform, I have to find something alternative to make my data extraction from WRDS replicable. Compiled from a series of WRDS guidances (you can find them in the **Reference** part), this blog will introduce how to exploit WRDS cloud via Python. 

The biggest advantage of WRDS Cloud is that you don't have to download everything to your computer but just deal with the massive data using the computing source of WRDS Cloud. Following this blog, one can quickly establish a python-wrds cloud workflow without checking various manuals.

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
    padding: 2px;">Figure 2: Connect to WRDS Cloud via SSH</div>
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

```shell
[xumj2019@wrds-cloud-login2-w ~]$ qrsh
Last login: Tue Oct 12 14:53:16 2021 from wrds-cloud-login2-w.wharton.private
[xumj2019@wrds-sas7-w ~]$ pip install wrds
Requirement already satisfied: wrds in /usr/local/sas/grid/python2-2.7.17/lib/python2.7/site-packages (3.0.8)
[xumj2019@wrds-sas7-w ~]$ ipython
Python 3.9.5 (default, May  6 2021, 14:32:00) 
Type 'copyright', 'credits' or 'license' for more information
IPython 7.23.1 -- An enhanced Interactive Python. Type '?' for help.
In [1]: 
```



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



## Explore WRDS Libraries and Tables

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



## Submit Queries

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
....
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

### Files in your WRDS Cloud

Insert `ls` in your ssh command line, you will find the files you've saved in your Wrds Cloud. Seems that you have got the files you desire but the files are stored in WRDS Cloud. The next step is to determine how to exchange files between your personal computer and the WRDS Cloud. 

After testing several alternatives (e.g., adopt an FTP server Cyberduck), I personally found linking WRDS with Dropbox is the most efficient way to do this job. [Transferring files using SCP](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/accessing-wrds-remotely-scp/) is also a good idea but it doesn't automatically backup your workflows as Dropbox does.

```python
[xumj2019@wrds-sas7-w ~]$ ls
autoexec.sas      testaq.sas                 WRDS_batch_ticker_ctm.sas
evt_taqinput.txt  test.csv                   WRDS_batch_ticker_ct.sas
myProgram.csv     WRDS_batch_ticker_cqm.sas
```

### Data Storage Locations

Having a big picture about how WRDS Cloud stores our files can make our file transferring job more intuitive. As the WRDS Cloud is a shared resource, with many hundreds of users accessing at any one time, this storage space is managed by a *quota*. Typically, there are two separate quota for your, depending on the storage locations and how long the WRDS Cloud keeps the data for you. Type `quota` in your command line, you will find how much storage you've used.

```shell
[xumj2019@wrds-cloud-login2-w xmj]$ quota
Current disk usage for xumj2019 (frankfurt):

DIRECTORY  USED / LIMIT
    Home:  548KB / 10GB
 Scratch:  220KB / 500GB

** Remember that the Scratch directory quota is shared **
** with all other members of your subscribing institution **

NOTE: Quota usage is updated every 30 minutes.
Last updated: 10/13/21 at 05:00 EDT


```

#### Permanent Storage - Home Directory

All users are given 10 GB dedicated permanent storage in their home directory in the WRDS Cloud.

Your home directory is located at:

**/home/[group name]/[username]**

- You may store up to **10GB** of data in this directory.
- Files in this directory are **never deleted** by WRDS.
- Files in this directory are **backed up via** **snapshots** created on a regular basis (see the *File Recovery* section, below)

**Note:** To determine your *group name*, use the `id` command on the WRDS Cloud: the name in the second set or parenthesis is your group name.  From my case below, it's easy to find my **group name** in WRDS is `frankfurt`

``` shell
[xumj2019@wrds-cloud-login2-w xmj]$ id
uid=323854(xumj2019) gid=60052(frankfurt) group=60052(frankfurt)
```

#### Temporary Storage - Scratch Directory

All subscribing institutions are given 500 GB shared temporary storage in the scratch directory. Generally, users should direct your larger output result data to this directory for staging before downloading, or before loading into subsequent programs. The scratch directory is located at:

**/scratch/[group name]**

- Members of your institution may store up to **500GB** of data in this directory, shared between all members.
- Files in your shared scratch directory are **deleted after one week (168 hours)**. 
- Files in this directory are **not backed up anywhere**, and should be downloaded shortly after being generated by your programs.

### Link WRDS with Dropbox

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
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-12%20%E4%B8%8B%E5%8D%884.42.14.png" width=500 height=250>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 3: Connect WRDS Cloud to Dropbox</div>
  </center>

- If you successfully logged in the command should print your dropbox account information. You may run `dbxcli account` again to confirm if your account is connected, if it prints your account information it is connected.

Once you've successfully link the wrds with your Dropbpox account, you could create a new folder in the Dropbox, say `testdir1013`

```python
[xumj2019@wrds-cloud-login2-w ~]$ dbxcli mkdir testdir1013
```

At the same time, you could also create a directory in your institution's scratch volume with a unique name. I would use `xmj` 

```python
[xumj2019@wrds-cloud-login2-w ~]$ mkdir /scratch/frankfurt/xmj/
```

### Transfer Files From WRDS to Dropbox

Files can be transferred to Dropbox with the `put` subcommand.

1. Make a directory in your institution's [scratch volume](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/storing-your-data-wrds-cloud/) with a unique name, such as your username. (I've introduced this part in **Data Storage Locations section**)

2. Run your job and save your output to this directory. For example, I save a csv file `test1013.csv` and a graph file `testgraph1013.png` into the scratch direcory I've created before **/scratch/frankfurt/xmj/**

   ```python
   In [7]: import matplotlib.pyplot as plt
   
   In [8]: data = db.raw_sql("select date,dji from djones.djdaily", date_cols=['dat
      ...: e'], index_col=['date'])
   
   In [9]: plt.plot(data)
   Out[9]: [<matplotlib.lines.Line2D at 0x2ba61364ad90>]
   
   In [10]: plt.xlabel('date')
   Out[10]: Text(0.5, 0, 'date')
   
   In [11]: plt.ylabel('dji')
   Out[11]: Text(0, 0.5, 'dji')
   
   In [12]: plt.show()
   
   In [13]: plt.show()
   
   In [14]: plt.savefig('/scratch/frankfurt/xmj/testgraph1013.png') 
                                                                               
   In [14]: data.to_csv("/scratch/frankfurt/xmj/test1013.csv")
   ```

3. When you are done go to the login node and `cd` to your scratch directory.

   ```python
   In [15]: quit()
   [xumj2019@wrds-sas5-w ~]$ logout
   [xumj2019@wrds-cloud-login2-w xmj]$ cd /scratch/frankfurt/xmj/
   ```

4. Once here transfer your file(s) from WRDS to Dropbox with `dbxcli put`.

   ```python
   [xumj2019@wrds-cloud-login2-w xmj]$ dbxcli put test1013.csv /testdir1013/test1013.csv
   Uploading 25 KiB/25 KiB
   [xumj2019@wrds-cloud-login2-w xmj]$ dbxcli put testgraph1013.png /testdir1013/testgraph1013.png
   Uploading 21 KiB/21 KiB
   ```

   Then you will find the files show up in your Dropbox

   <center>
       <img style="border-radius: 0.3125em;
       box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
       src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-10-13%20%E4%B8%8A%E5%8D%8810.48.20.png" width=500 height=100>
       <br>
       <div style="color:orange; border-bottom: 1px solid #d9d9d9;
       display: inline-block;
       color: #999;
       padding: 2px;">Figure 4: Transfer Files From WRDS to Dropbox</div>
   </center>

### Transfer Files From Dropbox to WRDS

Files can be transferred to WRDS Cloud with the `get` subcommand.

1. `cd` to your scratch directory or home directory, depending on whether you want the files to be stored permanently or temporarily in the Cloud.

    ```python
    [xumj2019@wrds-cloud-login2-w xmj]$ cd /scratch/frankfurt/xmj/
    ```

2. Once here transfer your file(s) to WRDS with `dbxcli get`. With the following code, I can transfer the `test.csv` located in my Dropbox root folder to the scratch volume. Type `ls` in the WRDS command line,  and one will find the `test.csv` have been successfully listed in my scatch directory. 

   ```PYTHON
   [xumj2019@wrds-cloud-login2-w xmj]$ dbxcli get test.csv .
   Downloading 93 KiB/93 KiB 
   [xumj2019@wrds-cloud-login2-w xmj]$ ls
   test1013.csv  test.csv  testgraph1013.png
   ```

   

## References

- [PYTHON: On the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/python-wrds-cloud/)
- [Submitting Python Jobs](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/submitting-python-programs/)
- [Login to the WRDS cloud via ssh](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/using-ssh-connect-wrds-cloud/) 
- [Interactive Jobs on the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/running-jobs/interactive-jobs-wrds-cloud/)
- [Querying WRDS Data using Python](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/querying-wrds-data-python/)
- [Example Python Data Workflow](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/python-example-data-workflow/)
- [Storing Your Data on the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/storing-your-data-wrds-cloud/)
- [Transfering Data with Dropbox](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/transfering-data-with-dropbox/)
- [Storing Your Data on the WRDS Cloud](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/storing-your-data-wrds-cloud/)
- [Graphing Data using Python](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-python/graphing-data-python/)
- [Transferring Files using SCP](https://wrds-www.wharton.upenn.edu/pages/support/the-wrds-cloud/managing-data/accessing-wrds-remotely-scp/)

