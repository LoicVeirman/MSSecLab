# MSSecLab
Tools to setup or works within a lab environment.

# About this repo
Hi everyone! This is the scripts I'm used to run when I build a lab or test things. 
Working with scripts helps in saving me time and ensure a proper environment reproduction when I rebuild them.

# How-to use it
Each script is stored in a folder. Each folder contains a release number, which in turn contains the code. Just download  this and start using it!

# Scripts
-----------------------------------
001 - ADVE (AD Virtual Environment)
-----------------------------------
 ADVE is a set of scripts to provision a test AD. 
 This is not the funiest one I've made, compare to HardenAD (ADVE was the 0.0 release), but it does the job.
 You'll find in: a script to install ADDS and a script to configure ADDS (including generate OU tree, etc.).

---------------------------
002 - HmD! (Hire my Dudes!)
---------------------------
 HmD! is a script to populate you active directory test lab.
 The script uses a repository of preconfigured people to hire (surname, givenname, address, ...) and pick-up randomly a set of user to add to your AD.
 This script is still under development (2022/09/06).
