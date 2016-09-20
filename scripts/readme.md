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

This script controls admin helps and admin PMs being sent to slack, the game world interacts with these by calling them as shell scripts. You must add your personal slack token to your systems enviroment variables. This script is no longer being used due to a migration to discord, but setting it up again should not be difficult.

#### Discord_bot.py

Dependencies: [discord.py](https://github.com/Rapptz/discord.py), Discord API token, python 3.4+

```
pip install discord.py --upgrade
export DISCORDTOKEN [token]
```

Similar to slack.py, this script sends ahelps to discord. The script itself requires some configuration (server and text channel IDs), and as with the slack script, you need to add the bot user's token to your environment variables.
Aditionally the script can be ran on the background aswell and intercept messages starting witht ! in the assigned channel. These will be forwarded as ahelp to players in the server.

#### Adminbus.py

Dependencies: [SlackClient](https://github.com/slackhq/python-slackclient), Slack API token

```
pip install SlackClient --upgrade
export SLACKTOKEN [token]
```

This script is Depreciated and has been replaced with `slack.py` and only exists for legacy reference.

#### PullFromWiki.py

Dependencies: [BeautifulSoup](http://bazaar.launchpad.net/~leonardr/beautifulsoup/3.2/files) python 2.7+`

pip install BeautifulSoup --upgrade

This script is used to pull forms from the wiki, do some processing and store them in a txt file.