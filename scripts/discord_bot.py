import discord
import asyncio
import os
import re
from sys import argv
from os import environ
### config
server_id = '204308700477915136' #server id goes here
channel_id = '207995528779137024' #ahelp channel id goes here
###

client = discord.Client()

#Runs every seccond in the background to push the buffer forward.
async def my_background_task():
    await client.wait_until_ready()    
    while not client.is_closed:
        found = 0
        for filename in os.listdir('.'):
            if filename.startswith("ahelps"):
                found = 1
                break
        if found == 0:
            #For some reason it ignores the startwith statement the first run so we let it fail.
            try:
                os.rename("w_ahelps.txt", "ahelps.txt")
            except FileNotFoundError:
                await asyncio.sleep(1)
        await asyncio.sleep(1) # task runs every seccond

# send the ahelp as soon as the client is ready to be used
@client.event
async def on_ready():
	server = client.get_server(server_id)
	ahelp_channel = server.get_channel(channel_id)

	if(len(argv) < 3):
		#if no args are passed we are running on loop mode.
		await client.send_message(ahelp_channel, "Sending off Hermes")
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
        myfile = open("w_ahelps.txt", "a", encoding='utf-8')
        myfile.write(str("start_ahelp" +"\n" + mod + "\n" + ckey + "\n" + message + "\n" + "stop_ahelp\n"))
        myfile.close()

#If we are running on loop tell the program we are running on loop
if(len(argv) < 3):
    client.loop.create_task(my_background_task())
    #client.run(bot_token)
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
