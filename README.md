# DCS-Scripts
A small collection of scripts for DCS


Drop in scripts to handle IADS and splash damage model changes.

Will update with more informaiton soon.

## IADS tips:

### INSTALLATION:
 Load at mission start in mission editor using Trigger> 4 Mission Start > Do Script File (this file)

 No naming required.
 
 Works on red coalition ground units for now.
 
 SAMs within 80km of an EWR are considered controlled, will only turn on when a blue air unit is in the air within ranges specified at the top of the file
 
 Uncontrolled SAMs will blink on and off
 
 HARMs and other ARMs detected by EWRs and SAMs have a chance of causing defensive behaviour in the SAM sites
 
 TORs remain on
 
### Mission Designer tips:
 Don't mix EWR and SAM sites in one group
 
 Don't mix SAM types in one group

## Damage Model Script:

### INSTALLATION:
 Load at mission start in mission editor using Trigger> 4 Mission Start > Do Script File (this file)

Improves splash damage modelling by pulling weapon warhead info (where available) and using this to create explosions (only way to apply damage) to units in more sensible range. 

## Weapon Damage Updates:

It has been discovered that ED model explosions quite well, but have no idea what comp B, comp H6 and TNT equivalence is. 

To this end, the new script causes a correct size explosion on impact point. It looks less visually jarring and should be more accurate damage wise and a LOT more efficient in terms of overhead. 

Tracking is also more accurate so impacts should be long/short less. 

I will say, it is less OP than the old version, and a little harder to see working, but it does, 
----------------------------------------------------------------------------------------------------------------------------------------------------
