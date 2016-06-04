#Usage: python update_message.py [timestamp] [user] [message]
from slackclient import SlackClient
import sys, os

#Loads the slack token - set this with '$~ export SLACKTOKEN [token]'
sc = SlackClient(os.environ['SLACKTOKEN'])

#updates a message given a timestamp		-- channel needs to be in ID form cause lazy
sc.api_call("chat.update", \
			ts=sys.argv[1], \
			channel="G1DDCRNN7", \
			text=sys.argv[3:][0].replace("&#39;","'").replace("&#34;", "\"").encode('ascii',errors='ignore')+"~    @" + sys.argv[2], \
			username="apollo", \
			as_user="true", \
			link_names="true")
