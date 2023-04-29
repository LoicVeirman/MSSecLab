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

-------------------------------------------
003 - Fix-ADuserDisabledSecurityInheritance
-------------------------------------------
 This is a script to use in a remediation where you need to revert massively all non-protected user objects?
 The script recover all users that are not set with the AdminAccount equal to 1, then check if the security inheritance is enabled, as it should.
 If not, then the script will revert the security permission to their factory defaults with a DACLS command.