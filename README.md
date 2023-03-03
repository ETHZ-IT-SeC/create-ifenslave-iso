Documentation and Helper Scripts to Install Debian with active LACP
===================================================================

This is basically what I did and wrote when I had to install a server
via the manufacture-provided Remote Console whereas the server's only
network connection were two bonded/teamed network interfaces which
were configured to use LACP on the switch side.

And since the Debian Installer doesn't support LACP, we need to
reorder some stuff and trick the `netinst` installer image into
configuring the network, but not using it.

And since usually the only option to get files on to the new server
via Remote Console but without network is via some local ISO image
mounted via the web interface of the Remote Console, the script in
this repo creates an ISO image which contains all the `.deb` files
needed to get LACP up and running, including some tools to debug
low-level networking as well as the possibility to add additional
packages for your own convenience.


Prerequisites
-------------

* Debian Installer images, either the [free version without non-free
  firmware
  blobs](https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/)
  or the [non-free version with non-free firmware
  blobs](https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/)

* Needs to be run on the same Debian (or Derivative) release as the
  target release. (Most of the documentation assumes this to be Debian
  Stable in general and Debian 11 Bullseye specifically.)

* The following packages need to installed:

  * [genisoimage](https://packages.debian.org/genisoimage)

* Clone this repo: `git clone
  https://github.com/xtaran/create-ifenslave-iso.git`
  
* Change into the newly checked out working copy: `cd
  create-ifenslave-iso`.
  
* Have look at the script and the create a `packages.local` file if
  you want additional packages in your ISO image. See
  `packages.local.example` for an example for such a file.
  
  I recommend to add your favourite editor (in case it isn't one of
  Debian's default editors, namely `vim-tiny` or `nano`) and its
  non-default dependencies.
  
* Run `./create-ifenslave-iso.sh`

You should have gotten a file named e.g. `ifenslave-bullseye.iso` if
you ran the script on Debian 11 Bullseye.


Workflow
--------

### Basic Installation

Use the installer as you're used to do, but:

* Either just configure one interface statically, or
* Don't configure network at all.

Finish everything else.

Reboot into the newly installed system which still has no working
network connection.

### Mount the ISO and install all the packages on it.

Mount the newly generated ISO image via Remote Console's media
management.

Log in as root (or as your user and then use `sudo` if you prefered
that at installation time).
  
Run these commands with root privileges:

```sh
mount /media/cdrom
dpkg -i /media/cdrom/*.deb
```

### Configure the Network and the APT Mirror

You can either edit the files `/etc/network/interfaces` and
`/etc/apt/sources.list` by hand or use the example files included in
the ISO (i.e. `/media/cdrom/interfaces` and `/media/sources.list`) and
modify them as needed:

You can safely overwrite `/etc/apt/sources.list` with the file
included in the ISO as the generated one won't contain anything
useful which isn't in here, too (except maybe if you didn't want
security updates — and you do want them ;-) or if you enabled the
`updates` repo.

```sh
cp -v /media/sources.list /etc/apt
editor /etc/apt/sources.list
```

You might want to change the used generic mirror with a local mirror.

Be more careful with the `/etc/network/interfaces` file. I recommend
to only append the file included in the ISO:

```sh
cat /media/cdrom/interfaces >> /etc/network/interfaces
editor /etc/network/interfaces
```

You especially need to edit the following sections:

* If you've configured a static IP address, copy the parts from the
  configured hardware interface to the section of the `bond0`
  interface and remove or comment our the remaining original interface
  section.
  
* If you've configured DHCP, just remove or comment out the full
  original interface section.

* In any case edit the file and make sure the line with the keyword
  `slaves` lists the actual interface names on which the LACP is
  configured.
  
Check if `ifup bond0` gives you a working network connection. If not,
check what part of the configuration might be wrong. `tcpdump` and
`ethtool` were installed before for debugging such cases.

### Apply Security Updates

Run e.g.

```
apt update
apt upgrade
reboot
```

(Reboot only necessary if there were security updates to the init
system, kernel or libc.)


Author
------

Axel Beckert <axel@ethz.ch> for the [ETH Zurich IT Security
Center](http://www.security.ethz.ch/).


Copyright
---------

© 2022 Axel Beckert <axel@ethz.ch>, ETH Zurich IT Security Center


License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
