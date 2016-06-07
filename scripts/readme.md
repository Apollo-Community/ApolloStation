# Apollo Station  [![Build Status](https://travis-ci.org/Apollo-Community/ApolloStation.svg?branch=master)](https://travis-ci.org/Apollo-Community/ApolloStation)

[Website](https://apollo-community.org/) - [Code](https://github.com/Apollo-Community/ApolloStation) - [IRC](https://apollo-community.org/viewforum.php?f=42)

---
### SCRIPTS

This folder contains scripts that are used on ApolloStation to improve functionality and monitor performance. In order for these scripts to work you ***must*** run your project in trusted mode.

`DreamDaemon apollo.dme [port] -trusted`

### INSTALLATION

#### Graph.py

Dependencies: [pandas](https://github.com/pydata/pandas), [matplotlib](https://github.com/matplotlib/matplotlib)

`pip install pandas matplotlib --upgrade`

Generates a graph of CPU and Tick Usage directly from a live server. Writes the file to `data/graphs/*.png` for sending to administrators via ftp().

#### Slack.py

Dependencies: [SlackClient](https://github.com/slackhq/python-slackclient), Slack API token

```
pip install SlackClient --upgrade
export SLACKTOKEN [token]
```

This script controls admin helps and admin PMs being sent to slack, the game world interacts with these by calling them as shell scripts. You must add your personal slack token to your systems enviroment variables.

#### Adminbus.py

Dependencies: [SlackClient](https://github.com/slackhq/python-slackclient), Slack API token

```
pip install SlackClient --upgrade
export SLACKTOKEN [token]
```

This script is Depreciated and has been replaced with `slack.py` and only exists for legacy reference.
