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
 Don't mix EWR and SAM sites
 
 Don't mix SAM types

## Damage Model Script:

### INSTALLATION:
 Load at mission start in mission editor using Trigger> 4 Mission Start > Do Script File (this file)

Improves splash damage modelling by pulling weapon warhead info (where available) and using this to create explosions (only way to apply damage) to units in more sensible range. 


----------------------------------------------------------------------------------------------------------------------------------------------------

Copyright (c) 2021 Wheelyjoe/A.G.P.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
