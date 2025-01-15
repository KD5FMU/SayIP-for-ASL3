![HRC Logo]([https://github.com/KD5FMU/SayIP-for-ASL3/sayip.jpg](https://github.com/KD5FMU/SayIP-for-ASL3/blob/main/sayip.jpg?raw=true))

# SayIP-for-ASL3
Here is an ASL3 Script to Speak the IP at BootUp


Here is a wonderful script from the brain of Jory Pratt - W5GLE to get your AllStarLink V3 AllStar Node to speak it's IP address. It will speak the Local IP or Public IP address. It will also reboot or halt your node with the correct DTMF Command. Some of our verteran HamVoIP users that have migrated to ASL3. Thank You Jory for this wonderful addition to our journey. 

- [Installation](#installation) 
- [Operation](#operation)

# Installation

## Command Lines for Installation

Here is how to install it.
First lets go to the root
```
cd ~
```
Now lets down the intaller script file.
```
wget https://raw.githubusercontent.com/KD5FMU/SayIP-for-ASL3/refs/heads/main/asl3_sayip_reboot_halt.sh
```

Now we have to make that script executable
```
chmod +x asl3_sayip_reboot_halt.sh
```

Now that the file is executable we can go ahead and run the script file to install these features.
```
sudo ./asl3_sayip_reboot_halt.sh YOUR_NODE_NUMBER
```

# Operation

```
*A1 = Say Local IP address of the node
*A3 = Say Public IP address of the node
*B1 = is a HALT command to the node
*B3 = is a REBOOT command for the node
```
If you do not wish to have your node speak its Local IP address upon boot you can simply disable it
```
sudo nano -w /etc/asterisk/local/allstar.env 
```



