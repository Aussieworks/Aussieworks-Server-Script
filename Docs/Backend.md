1.Install python<br/>
  https://www.python.org/
	
2.Execute the following command in a command prompt window
```
py -m pip -r install <path/to/requirements.txt>
```
3.Create the following directories
```
c:\swds
c:\swds\servers
c:\swds\servers\backend
c:\swds\servers\server1
c:\swds\servers\server2
```
Each server folder should have a folder called
```
config_data
```
4.Copy server_config.xml to the server1 directory

5.Copy backend scripts to c:\swds\backend

6.Create servers.json<br/>
	Write the following in a text editor and save as servers.json
	The servers.json is stored in the backend directory.
```
{"servers": [{"number":<server number>,"name":"<name of server>"}]}
```
  Here is an example of one with multiple servers
```
{"servers": [{"number":1,"name":"test1"},{"number":2,"name":"test2"},{"number":3,"name":"test3"}]}
```
7.Create webhooks<br/>
	Create based on the knowledge presented by Discord.
	https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks

8.Change the URL of the webhook in start_backend.py

9.Install auscode into each server

10.Execute server_control.py and start_backend.py
