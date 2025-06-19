# Installation
1. After downloading the [latest](https://github.com/Aussieworks/Aussieworks-Server-Script/releases) version of `auscode`, unzip the zip file and go into the folder and copy the folder named `newauscode`.
2. Go to `%appdata%/Stormworks/data/missions` or where your server files are located and paste the `newauscode` folder.
3. Go to your servers `server_config.xml` file and add `<path path="/rom/data/missions/newauscode"/>` into the playlist section.
4. Go to the `script.lua` located in the `newauscode` folder and configure the addon.
5. Start your server and join.

>[!TIP]
>A good way to see if the `auscode` addon is enabled it to run the command `?ver`. It should comes up with `"[AusCode] |AusCode version: {the auscode version you are using}"` in chat. if this is not the case, run `?reload_scripts` it should come up with `"[AusCode]  AusCode reloaded"` in chat. else follow the instalation steps again.
# Updating
1. After downloading the [latest](https://github.com/Aussieworks/Aussieworks-Server-Script/releases) version of `auscode`, go into the zip file and copy the folder named `newauscode`.
2. Go to `%appdata%/Stormworks/data/missions` or where your server files are located and paste the `newauscode` folder. it should come up with a promt saying something along the lines of do you want to replace these files, click yes. If you want to keep your settings i would recommend copying the old `auscode` folder somewhere else and then manually copying over the settings into the new `script.lua`. 
3. If the server is running you should be able to run `?reload_scripts`. to check if it worked run `?ver` and see if the version matches the version you downloaded. otherwise start the server and then check the version.
