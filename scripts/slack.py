#Usage = python slack.py [source] [target ? sends ahelp : sends pm] [message]
from slackclient import SlackClient
from sys import argv
from os import environ

sc = SlackClient(environ['SLACKTOKEN'])
message =  ' '.join(argv[4:]).replace("&#39;","'").replace("&#34;", "\"").encode('ascii',errors='ignore')

#build the payload
data = '[{"color": "'
if(argv[2] == '1'):		#if its an ahelp
	data += 'danger'
	data += '", "pretext": "*AHELP:* `' + argv[1] + '`", "text": "' + message 		# using join() incase we get sent the data in a list
else:				#its a standard pm
	if(argv[3] == '0'):		#set the color depending on the direction of PM
		data += 'good'
	else:
		data += 'warning'
	data += '", "pretext": "*PM:* `' + argv[1] + '->' + argv[2] + '`", "text": "' + message

data += '","mrkdwn_in": ["pretext"]}]'		# Don't use markup in the ahelp content

#send it to slack
sc.api_call(	"chat.postMessage", \
				channel = "ahelp",\
				attachments=data,\
				username="apollo",
				as_user="true")