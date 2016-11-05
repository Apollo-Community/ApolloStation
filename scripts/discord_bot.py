import discord, socket, struct, time, asyncio, os, re, atexit, sys, signal
from sys import argv
from os import environ
### config
server_id = '204308700477915136' #server id goes here
channel_id = '207995528779137024' #ahelp channel id goes here
channel_common = '204308700477915136'
channel_announcements = '205830727592443904'
channel_staff = '204309247968673801'
#server IP and Port
ip = '127.0.0.1'
port = 3333
###
client = discord.Client()
# send the ahelp as soon as the client is ready to be used
@client.event
async def on_ready():
        if(len(argv) < 3):
                return
        if(argv[1] == "command"):
                await adv_commands()
                return
        message = ''
        if argv[2] == '1':
                message = '**AHELP:** _' + argv[1] + '_```' + argv[3] + '```'
        else:
                message = '**PM:** _' + argv[1] + '_ -> _' + argv[2] + '_```' + argv[3] + '```'
        server = client.get_server(server_id)
        ahelp_channel = server.get_channel(channel_id)
        await client.send_message(ahelp_channel, message)
        await client.close()

#Sends a message to a given channel determined by argvs the scripts it called with.
async def adv_commands():
        server = client.get_server(server_id)
        channel = server.get_channel(channel_id)
        temp_channel = channelFromString(argv[2])
        if not (channel == 0):
                channel = temp_channel
        message = argv[3] + '```' + argv[4] + '```' #argv[3] contains author, argv[4] message
        await client.send_message(channel, message)
        await client.close()
        

#When a message is sent to the right channel on discord run this.
#Message will be sent along to be exported to the byond server.
@client.event
async def on_message(message):
    if(len(argv) < 3):
        server = client.get_server(server_id)
        if not message.content.startswith('!'):
                return
        #private = message.channel.is_private
        objauthor = message.author
        author = str(message.author)
        channel = message.channel
        message = message.content
        if(message == "!help"):
                message = '```!help for a list of commands.\n\n'
                message += 'Commands in general:\n\n'
                message += '!staffwho for a list of staff members ingame.\n\n'
                message += '!players for a list of players ingame.\n\n'
                message += '!uptime for the current round duration.```'
                await client.send_message(channel, message)
                return
        
        elif channel == server.get_channel(channel_id):   #its in the ahelp channel.
                pm_list = re.split('\s+', message)
                ckey = pm_list[0]
                message = message.replace(ckey,"")
                ckey = ckey.replace("!","")
                message = message.replace('\n',"")
                message = message[1:]
                mod = re.sub('[^A-Za-z0-9]+', '', author)
                ckey = re.sub('[^A-Za-z0-9]+', '', ckey)
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                print(ckey, mod, message)
                await byond_export('adminmsg'+'&target='+ckey+'&admin='+author+'&text='+message)
                return
                
        elif channel == server.get_channel(channel_common):     #Its in the general channel
                message.replace("!","")
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                await byond_export('gencom'+'&command='+message+'&author='+author)
                return
                
        elif channel == server.get_channel(channel_staff): # or private:     #Its in the staff channel
                if(message.startswith('!logs')):
                        message = message[6:]
                        if await printLogs(message, objauthor, channel) == 0:
                                await client.send_message(channel, "WARNING: You either had a typo or something is wrong with the bot permissions. Contact a developer.")
                        return
                message.replace("!","")
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                await byond_export('modcom'+'&command='+message+'&author='+author)
                return

#Utility function to get a channel from a string
#Returns 0 if fail, return a channel if succes.
def channelFromString(string):
        server = client.get_server(server_id)
        for c in server.channels:
                if str(c) == string:
                        return c
        return 0

#Log the last 1000 messages in a txt file and sent it to the user.
async def printLogs(channel, author, channel_from):
        channel = channelFromString(channel)
        if(channel == 0):
                return 0
        logs = ["---------END OF LOG---------"]
        async for message in client.logs_from(channel, limit=1000):
                logs.append(str(message.timestamp) + ":" + re.sub('[^A-Za-z0-9]+', ' ', str(message.author) + ": " + message.content))
        logs = logs[::-1]
        logs.insert(0, "CHANNEL LOGS OF: " + str(channel) + " GENERATED FOR: " + str(author))
        logs = "\n".join(logs)
        flogs = open("dlogs.txt", "w")
        flogs.write(logs)
        flogs.close()
        flogs = open("dlogs.txt", "rb")
        await client.send_file(author, flogs, filename="Logs.txt", content="Logs from "+str(channel))
        flogs.close()
        #binurl = createPaste(logs, api_paste_name='Logs From: '+str(channel), api_paste_format='', api_paste_private='1', api_paste_expire_date='1D')
        #await client.send_message(author, "Logs Pastebin URL: " + binurl, tts=False)
        
#Mimic byond world export to call world/topic() with given string
async def byond_export(string):
        packet_id = b'\x83'
        try:
                sock = socket.create_connection((ip, port))
        except socket.error:
                server = client.get_server(server_id)
                ahelp_channel = server.get_channel(channel_id)
                await client.send_message(ahelp_channel, "WARNING: Failed to connect to IP:"+ip+":"+str(port))
                return
        packet = struct.pack('>xcH5x', packet_id, len(string)+6) + bytes(string, encoding='utf-8') + b'\x00'
        sock.send(packet)
        data = sock.recv(512)
        sock.close()

#If we are running on loop tell the program we are running on loop
if len(argv) < 3:
        client.run(environ['DISCORDTOKEN'])

#Else we are not running on loop so tell it to stop when its done.
elif len(argv) >= 3:
	# not using client.run() because this way we can close the connection immediately after sending the ahelp as opposed to having the bot run on the server continually
	try:
		client.loop.run_until_complete(client.start(environ['DISCORDTOKEN']))
	finally:
		client.loop.run_until_complete(client.logout())
		client.loop.close()
