---

title:       "Parse Twitter: Introduction to Twitter API 2.0"
subtitle:    ""
description: "Parse Twitter"
date:        2021-06-14
author:      ""
image:       "images/noaa.jpeg"
tags:        ["NOAA", "Geo-Economics"]
categories:  ["Tech" ]

---



```python
import requests
import os
import json
import csv
import time
from tqdm import tqdm

# To set your environment variables in your terminal run the following line:
# export 'BEARER_TOKEN'='<your_bearer_token>'
# Or set bearer_token in the code directly
# bearer_token = "xxx"

search_url = "https://api.twitter.com/2/tweets/search/all"

# Optional params: start_time,end_time,since_id,until_id,max_results,next_token,
# expansions,tweet.fields,media.fields,poll.fields,place.fields,user.fields
def setpara(firm,start_time,end_time):
    query_params = {'start_time': "%s"%start_time, 'end_time':"%s"%end_time,
    'query': "%s"%firm, 'tweet.fields': "created_at,public_metrics,author_id,geo,lang,non_public_metrics,promoted_metrics",'max_results': 10}
    return(query_params)

def create_headers(bearer_token):
    headers = {"Authorization": "Bearer {}".format(bearer_token)}
    return headers

def connect_to_endpoint(url, headers, params):
    response = requests.request("GET", search_url, headers=headers,params=params)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()

def updatepara(oldpara, next_token):
    newpara = {**oldpara,**{'next_token':next_token}}
    return(newpara)

def csvjson(firm, start_time, end_time, json_response):
    meta = json_response['meta']
    callnum = meta['result_count']
    try:
        next_token = meta['next_token']
    except:
        next_token = False
    empty = (callnum==0)
    with open("/Users/mengjiexu/Documents/meta.csv",'a') as g:
        now = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        g.write(",".join([firm, start_time, end_time,now, repr(callnum), str(next_token)])+'\n')
    
    if not empty:
        with open("/Users/mengjiexu/Documents/%s_%s_%s.csv"%(firm, start_time,end_time),'a') as f:
            w = csv.writer(f)
            tweets = json_response['data']
            for tw in tweets:
                created_at = tw['created_at']
                tweet = tw['text'].encode('utf-8').decode('utf-8')
                list = [tw['created_at'], tweet,tw['text'],tw['public_metrics']['retweet_count'],tw['public_metrics']['reply_count'], tw['public_metrics']['like_count'], 
                tw['author_id'], ",".join(tw['geo']["coordinates"]["coordinates"]), tw['lang'], tw['non_public_metrics']["impression_count"], tw['non_public_metrics']["url_link_clicks"],
                 tw['non_public_metrics']["user_profile_clicks"], tw['promoted_metrics']['impression_count']]
                print(list)
                w.writerow(list)
    
    return(next_token)

def dealjson(firm, start_time, end_time, json_response):
    headers = create_headers(bearer_token)
    next_token = csvjson(firm, start_time, end_time, json_response)
    
    while next_token:
        newpara = updatepara(setpara(firm,start_time,end_time), next_token)
        time.sleep(3)
        json_response = connect_to_endpoint(search_url, headers, newpara)
        next_token = csvjson(firm, start_time, end_time, json_response)
        print(next_token)

def mainparse(firm,start_time,end_time):
    headers = create_headers(bearer_token)
    json_response = connect_to_endpoint(search_url, headers, setpara(firm,start_time,end_time))
    dealjson(firm, start_time, end_time, json_response) 
    #print(json.dumps(json_response, indent=4, sort_keys=True))
    
mainparse('AAPL', '2011-01-01T00:00:00Z','2011-04-01T00:00:00Z')

```

