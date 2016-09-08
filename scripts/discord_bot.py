import discord
import asyncio
from sys import argv
from os import environ

### config
server_id = '204308700477915136' #server id goes here
channel_id = '207995528779137024' #ahelp channel id goes here
###

client = discord.Client()

# send the ahelp as soon as the client is ready to be used
@client.event
async def on_ready():
	server = client.get_server(server_id)
	ahelp_channel = server.get_channel(channel_id)

	message = ''
	if argv[2] == '1':
		message = '**AHELP:** _' + argv[1] + '_```' + argv[3] + '```'
	else:
		message = '**PM:** _' + argv[1] + '_ -> _' + argv[2] + '_```' + argv[3] + '```'
	await client.send_message(ahelp_channel, message)

	await client.close()

# not using client.run() because this way we can close the connection immediately after sending the ahelp as opposed to having the bot run on the server continually
try:
	client.loop.run_until_complete(client.start(environ['DISCORDTOKEN']))
finally:
	client.loop.run_until_complete(client.logout())
	client.loop.close()