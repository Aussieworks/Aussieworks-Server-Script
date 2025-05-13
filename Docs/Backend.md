1.Install python<br/>
  https://www.python.org/
	
2.Execute the following command in a command prompt window
```
py -m pip -r install <path/to/requirements.txt>
```
3.Create the following folders
```
c:\swds
c:\swds\servers
c:\swds\servers\backend
c:\swds\servers\server1
c:\swds\servers\server2
```
Each server folder should have a folder called `config_data` in it along with a copy of the stormworks game files<br/>

4.Copy server_config.xml to the config_data folder of each server

5.Copy backend scripts into c:\swds\backend

6.Write the following in a text editor and save as `servers.json`. The `servers.json` is stored in the backend folder.
```
{"servers": [{"number":<server number>,"name":"<name of server>"}]}
```
  Here is an example of one with multiple servers
```
{"servers": [{"number":1,"name":"test1"},{"number":2,"name":"test2"},{"number":3,"name":"test3"}]}
```
7.Create a webhook for the channel you would like the server status to be in based on the knowledge presented [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) by Discord.<br/>

8.Change the URL of the webhook in start_backend.py to the one you just created.

9.Copy the auscode mission into each servers mission folder
>[!TIP]
>Dont forget to add it into the server_config.xml

10.Execute server_control.py and start_backend.py
