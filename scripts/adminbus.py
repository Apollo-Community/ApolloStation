#USAGE: python adminbus.py [slack_channel] [user] [message]
from slackclient import SlackClient
import sys, os, socket, struct

#Sends the timestamp back to the server
def send_data(user, timestamp):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect(('127.0.0.1', 3333))

	#Generates the query to send to the SS13 server
	senddata = "?admintime&user="+user+"&time="+timestamp
	#Crafts a fake world.Export()
	query  = '\x00\x83' + struct.pack(">H", len(senddata)+6) + '\x00'*5 + senddata + '\x00'
	s.send(query)

#Loads the slack token - set this with '$~ export SLACKTOKEN [token]'
sc = SlackClient(os.environ['SLACKTOKEN'])

#Calls Slack api and sends a message
out = sc.api_call(	"chat.postMessage", \
					channel="#"+sys.argv[1], \
					text=sys.argv[3:][0].replace("&#39;","'").replace("&#34;", "\"").encode('ascii',errors='ignore'), \
					username="apollo", \
					as_user="true", \
					link_names=1)

#Gets the timestamp from slack api and calls send_data([user], [timestamp])
time =  str(out).split(",")[3]
send_data(sys.argv[2], time[time.find(": u'")+4:-1])
