import discord
import asyncio
import os
import re
from sys import argv
from os import environ
### config
server_id = '204308700477915136' #server id goes here
channel_id = '207995528779137024' #ahelp channel id goes here
bot_token = 'MjI3MTk3ODA5NjgwNDQ5NTM2.CsCqFA.Qx4C-CeY6kCRVRYIQFa4rqfB1_0' #bots token goes here
###
client = discord.Client()

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

@client.event
async def on_ready():
	server = client.get_server(server_id)
	ahelp_channel = server.get_channel(channel_id)
	await client.send_message(ahelp_channel, "Hermes Online.")
	
@client.event
async def on_message(message):
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
	
client.loop.create_task(my_background_task())
client.run(bot_token)
