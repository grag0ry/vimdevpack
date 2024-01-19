#!/usr/bin/env python

import argparse
import re
import requests

parser = argparse.ArgumentParser(prog='github-assets')
parser.add_argument('-r', '--repository', type=str, required=True)
parser.add_argument('-v', '--version', type=str, default="latest")
parser.add_argument('-f', '--filter', type=str, default=".*")
args = parser.parse_args()

fre = re.compile(args.filter)

r = requests.get(f"https://api.github.com/repos/{args.repository}/releases/{args.version}")

for a in filter(lambda x: fre.search(x['name']), r.json()['assets']):
    print(a['browser_download_url'])
