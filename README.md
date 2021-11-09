# Hijacking Downlink Path Selection in LoRaWAN
Code repository with PoC of the attack for the paper "_Hijacking downlink communication in a LoRaWAN Network_" presented at Globecom 2021.

The attack blocks end-devices from receiving any downlink. It exploits the packet de-duplication and gateway selection inside the Network Server

## Attack scheme
Consider a victim device we want to target. Consider two legitimate LoRaWAN gateways Gw1 and Gw2. Let the target device be in the range of only Gw1 and not Gw2. We deploy two malicious LoRaWAN devices, a sniffer and a replayer. We place the sniffer close to target and the replayer very close to Gw2, in such a way to have an excellent link quality to Gw2 (in terms of RSSI, SNR or whatever). 

![qwerty](imgs/out.gif)
