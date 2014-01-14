---
title: Creating a Working SteamOS Installer on a Mac
date: 2014-01-14 11:30 -07:00
tags: mac, steamos, virtualbox
---

Ever since [SteamOS][steamos] released, I've been trying to get it installed into [VirtualBox][virtualbox].  When I
first started this process, I found the same [SteamOS Basic Guide Installation on VirtualBox][steamos-install-guide]
everyone else was using, or copying, and began trying to make this happen.  Since VirtualBox abstracts all the
hardware, I figured the installation process would be identical regardless of my operating system.  For the most part,
that is right.  Other than the creation of the ISO file, the installation process is identical regardless of your
operating system.  Unfortunately, this is where things go wrong for Mac users as there was no solid documentation on
how to create the ISO on Mac OS X.

Mac OS X includes utilities out of the box for things like this.  My assumption, like many others based on the
suggestions I found, was that I could use these tools to create an ISO from the provided zip file.  Even better news
was that the suggestions I were finding aligned with my assumption.  Based on my research, all of the suggestions on
the matter included one of the following approaches:

#### Disk Utility UI

* Open Disk Utility
* _New > Disk Image From Folder..._
* Select the folder you extracted the SteamOSInstaller.zip to
* Choose the hybrid-image _Image Format_

#### Disk Utility CLI

* Execute `hdiutil makehybrid -o PATH_TO_ISO PATH_TO_FOLDER -iso -joliet` from a terminal

Both of these worked at face value, an ISO was created from the zip file.  But unfortunately, whenever you tried to
follow the installation guide and use the ISO, you were very quickly faced with the following error message:
`error: "prefix" is not set`.  There was no recovery from this.  You could wait forever and VirtualBox would show
you the same screen.  Heck, I even tried booting into the EFI shell and loading the ISO manually to see if I could
somehow work around the situation.

Originally I had given up, I didn't want to waste anymore time on it and no one seemed to have an answer.  And then
today, for some odd reason, I tried it again, some weeks later since my original attempts.  I had hoped there was a
bug in the early release and that it had been fixed by now.  I rebuilt my ISO and tried again but to no avail, I got to
the same place with the same results.  Frustrated, I googled and came across the same posts.  It seems nothing has
changed.

I asked myself: _What is the difference between my attempt and the documented working attempts?_  That's when it
occurred to me that maybe the ISO being created using the options above didn't create a proper ISO.  Seems logical
since that is the only deviation I've made from the documentation.  So I went on the hunt for an installation guide
that used a tool to create the ISO that I could get installed on my Mac and that's when I found that [xorriso][xorriso]
was available via [Homebrew][homebrew].  After installing it, I was able to use the following command to create a
working SteamOS Installer ISO that works flawlessly via VirtualBox:

```
xorriso -as mkisofs -r -checksum_algorithm_iso md5,sha1 -V 'Steam OS' \
-o ../SteamOSInstaller.iso -J -joliet-long -cache-inodes -no-emul-boot \
-boot-load-size 4 -boot-info-table -eltorito-alt-boot --efi-boot boot/grub/efi.img \
-append_partition 2 0x01 boot/grub/efi.img \
-partition_offset 16 .
```

**Note:** The assumption here is that if you were to extract the zip file to a folder, you'd run this command while
within the folder, otherwise you'll need to alter the paths accordingly.  Also, feel free to change the `-o` option to
change the name and location of the created ISO file.

That pretty much wraps things up.  I'm excited to play around with SteamOS and while it was a pain to get started, due
to the dreaded `error: "prefix" is not set`, I've finally been able to get past this using the information above.  I
hope this information helps you other Mac users avoid the pain I originally did.

[homebrew]: http://brew.sh/
[steamos]: http://store.steampowered.com/livingroom/SteamOS/
[steamos-install-guide]: http://steamcommunity.com/sharedfiles/filedetails/?id=204085700
[virtualbox]: https://www.virtualbox.org/
[xorriso]: http://www.gnu.org/software/xorriso/