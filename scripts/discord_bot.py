import discord, socket, struct, time, asyncio, os, re
from sys import argv
from os import environ
### config
server_id = '204308700477915136' #server id goes here
channel_id = '207995528779137024' #ahelp channel id goes here
#server IP and Port
ip = '127.0.0.1'
port = 3333
###

client = discord.Client()
# send the ahelp as soon as the client is ready to be used
@client.event
async def on_ready():
        server = client.get_server(server_id)
        ahelp_channel = server.get_channel(channel_id)
        if(len(argv) < 3):
                #if no args are passed we are running on loop mode.
                #await client.send_message(ahelp_channel, "Sending off Hermes")
                print("bla")
        else:
                message = ''
                if argv[2] == '1':
                        message = '**AHELP:** _' + argv[1] + '_```' + argv[3] + '```'
                else:
                        message = '**PM:** _' + argv[1] + '_ -> _' + argv[2] + '_```' + argv[3] + '```'
                        await client.send_message(ahelp_channel, message)
                        await client.close()

#When a message is sent to the right channel on discord run this.
#Will process the message and append it to the buffer.
@client.event
async def on_message(message):
    if(len(argv) < 3):
        server = client.get_server(server_id)
        if message.channel != server.get_channel(channel_id):
                return
        if not message.content.startswith('!'):
                return
        mod = str(message.author)
        pm = message.content
        pm_list = re.split('\s+', pm)
        ckey = pm_list[0]
        message = pm.replace(ckey,"")
        ckey = ckey.replace("!","")
        message = message.replace('\n',"")
        message = message[1:]
        mod = re.sub('[^A-Za-z0-9]+', '', mod)
        ckey = re.sub('[^A-Za-z0-9]+', '', ckey)
        message = re.sub('[^A-Za-z0-9]+', '', message)
        byond_export('adminmsg'+'&target='+ckey+'&admin='+mod+'&text='+message)

def byond_export(string):
        print("exporting: "+string)
        packet_id = b'\x83'
        try:
                sock = socket.create_connection((ip, port))
        except socket.error:
                print("Failed to connect")
                return

        packet = struct.pack('>xcH5x', packet_id, len(string)+6) + bytes(string, encoding='ascii') + b'\x00'
        sock.send(packet)
        data = sock.recv(512)
        sock.close()

#If we are running on loop tell the program we are running on loop
if(len(argv) < 3):
       client.run(environ['DISCORDTOKEN'])
        
#Else we are not running on loop so tell it to stop when its done.
else:
	# not using client.run() because this way we can close the connection immediately after sending the ahelp as opposed to having the bot run on the server continually
	try:
		#client.loop.run_until_complete(client.start(bot_token))
		client.loop.run_until_complete(client.start(environ['DISCORDTOKEN']))
	finally:
		client.loop.run_until_complete(client.logout())
		client.loop.close()
