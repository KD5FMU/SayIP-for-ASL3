![sayiplogo Logo](https://github.com/KD5FMU/SayIP-for-ASL3/blob/main/sayip.jpg)

# SayIP-for-ASL3
Here is an ASL3 Script to Speak the IP at BootUp


Here is a wonderful script from the brain of Jory Pratt - W5GLE to get your AllStarLink V3 AllStar Node to speak it's IP address. It will speak the Local IP or Public IP address. It will also reboot or halt your node with the correct DTMF Command. Some of our verteran HamVoIP users that have migrated to ASL3. Thank You Jory for this wonderful addition to our journey. If for any reason you run into any issues please provide the info from the log file located at /var/log/asl3_sayip_setup.log

- [Installation](#installation) 
- [Operation](#operation)

# Installation

## Command Lines for Installation

Here is how to install it.
First lets go to the root
```
cd 
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
sudo systemctl disable allstar-sayip
```

👉 If you want to help Jory out with his efforts on making things better for all of us then please consider makeing a donation to his efforts.🇺🇸
---
<a href="https://www.paypal.com/donate?token=IyATJ7p91vnH0tLglypNy2DxIZ3G2VmpWddIzltxRzY4kpcF0hPRHPj7F9ipe3YvfujL-1een4QH5Te5" target="_blank">
  <img src="https://img.shields.io/badge/Donate%20with-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" />
</a>

<a href="https://cash.app/$anarchpeng" target="_blank">
  <img src="https://img.shields.io/badge/Donate-CashApp-00C244?style=for-the-badge&logo=cashapp&logoColor=white" />
</a>

<!-- Zelle uses email/phone inside your bank app; no public pay URL exists. -->
<a href="mailto:geekypenguin@gmail.com?subject=Zelle%20Donation%20for%20Jory%20Pratt%20-%20W5GLE&body=I%27d%20like%20to%20send%20a%20Zelle%20donation.">
  <img src="https://img.shields.io/badge/Donate%20via-Zelle-6D1E72?style=for-the-badge&logo=zelle&logoColor=white" />
</a>

**Send via Zelle to:** `geekypenguin@gmail.com` (Jory Pratt – W5GLE)





