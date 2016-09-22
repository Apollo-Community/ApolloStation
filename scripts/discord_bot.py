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
                adv_commands()
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

async def adv_commands():
        server = client.get_server(server_id)
        channel
        for c in server.channels:
                if str(c) == argv[2]:
                    channel = c
                    break

        message = argv[3] + '_' + '```' + argv[4] + '```' #argv[3] contains author, argv[4] message
        channel = server.get_channel(channel)
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
        author = str(message.author)
        message = message.content
        if message.channel == server.get_channel(channel_id):   #its in the ahelp channel.
                message = message.content
                pm_list = re.split('\s+', message)
                ckey = pm_list[0]
                message = message.replace(ckey,"")
                ckey = ckey.replace("!","")
                message = message.replace('\n',"")
                message = message[1:]
                mod = re.sub('[^A-Za-z0-9]+', '', mod)
                ckey = re.sub('[^A-Za-z0-9]+', '', ckey)
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                await byond_export('adminmsg'+'&target='+ckey+'&admin='+author+'&text='+message)
                
        elif message.channel == server.get_channel(channel_common):     #Its in the general channel
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                await byond_export('gencom'+'&command='+message+'&author='+author)
                
        elif message.channel == server.get_channel(channel_staff):     #Its in the staff channel
                message = re.sub('[^A-Za-z0-9]+', ' ', message)
                await byond_export('modcom'+'&command='+message+'&author='+author)

        
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
        packet = struct.pack('>xcH5x', packet_id, len(string)+6) + bytes(string, encoding='ascii') + b'\x00'
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
