# SayIP-for-ASL3
Here is an ASL3 Script to Speak the IP at BootUp


Here is a wonderful script from the brain of Jory Pratt - W5GLE to get your AllStarLink V3 AllStar Node Speak it's IP address. You can also make it speak your Outside or Public IP address. It will also reboot your node with the correct DTMF Command. Some of our verteran HamVoIP users that have migrated to ASL3. Thank You Jory for this wonderful addition to our journey. 

- [Installation](#installation) 
- [Configuration](#configuration)

# Installation

## Command Lines for Installation

Here is how to install it.
First lets go to the root
```
cd ~
```
Now lets down the intaller script file.
```
sudo wget https://raw.githubusercontent.com/KD5FMU/SayIP-for-ASL3/refs/heads/main/asl3_sayip_reboot_halt.sh
```

Now we have to make that script executable
```
sudo chmod +x asl3_sayip_reboot_halt.sh
```

Now that the file is executable we can go ahead and run the scrupt file to install these features.
```
sudu ./asl3_sayip_reboot_halt.sh
```

