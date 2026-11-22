# Server cutover: Arch to NixOS

Converts `server.lan` (192.168.86.10) from Arch to the `server` configuration in
this flake. Only the NVMe disk is reformatted. The two RAID arrays
(`/media/media`, `/media/backup`) are never written to by the installer and are
mounted by UUID afterwards.

Expect one to two hours of downtime. You need a monitor and keyboard on the
server for the first minutes of the install, and a USB stick with a recent NixOS
minimal ISO.

Everything staged for the move lives in `/media/backup/cutover`, referred to as
`$C` below.

## What moves and where

| State | Arch location | NixOS location |
|---|---|---|
| Nextcloud files | `/var/lib/nextcloud/data` | same |
| Nextcloud config | `/etc/webapps/nextcloud/config/config.php` | `/var/lib/nextcloud/config/config.php` |
| Nextcloud app `gpoddersync` | `/var/lib/nextcloud/apps/` | `/var/lib/nextcloud/store-apps/` |
| Nextcloud database | MariaDB 13.0 | MariaDB 11.4, via SQL dump |
| Sonarr, Radarr, Readarr | `/var/lib/<app>` | same |
| Prowlarr | `/var/lib/prowlarr` | `/var/lib/private/prowlarr` |
| NZBGet config | `/var/lib/nzbget` | same |
| calibre-web | `/usr/lib/calibre-web/{app,gdrive}.db` | `/var/lib/calibre-web/` |
| calibre-web (Vegan) | `/usr/lib/calibre-web/vegan.db` | `/var/lib/calibre-web-vegan/app.db` |
| Compose projects | `/opt/docker`, `/opt/immich-app` | same |
| Local images | docker: `torbox`, `media-prod`, `media-lists` | `docker load` |
| SSH host keys | `/etc/ssh/ssh_host_*` | same |
| Home directory | `/home/igray` (without `.cache`) | same |

Not carried over: `/etc/letsencrypt` (new certificates are issued on first
boot), `/var/lib/docker` (images are pulled again), and the state of everything
on the dropped list.

Jellyfin, Transmission, Music Assistant, AIOStreams, TorBox and media-lists keep
their state under `/media/media/incoming`, so they need nothing.

## 1. Before the day

On the laptop, in this repo:

1. Commit the server config. The installer builds from a copy of the repo and a
   flake only sees files git knows about.
2. Build it once to prove it builds:

   ```bash
   nix build .#nixosConfigurations.server.config.system.build.toplevel --no-link
   ```

3. Rehearse the database downgrade. The dump goes from MariaDB 13.0 to 11.4,
   which is the step most likely to need fixing, so find out now:

   ```bash
   ssh server.lan 'sudo mariadb-dump --single-transaction nextcloud' > /tmp/nc-test.sql
   docker run -d --name nc-test -e MARIADB_ROOT_PASSWORD=test -e MARIADB_DATABASE=nextcloud mariadb:11.4
   sleep 30
   docker exec -i nc-test mariadb -ptest nextcloud < /tmp/nc-test.sql
   docker exec nc-test mariadb -ptest nextcloud -e 'select count(*) from oc_filecache'
   docker rm -f nc-test && rm /tmp/nc-test.sql
   ```

   If the import errors, fix the dump (usually a collation or a `CREATE TABLE`
   option the older version rejects) and note the fix for step 2.

4. Write the NixOS minimal ISO to a USB stick.
5. Confirm ports 80 and 443 are forwarded to 192.168.86.10. Certificate issuance
   on first boot depends on port 80.

## 2. Stage the state (on Arch, downtime starts)

```bash
ssh server.lan
sudo -i
C=/media/backup/cutover
mkdir -m 700 -p $C
```

Stop the backup timers so nothing else is writing to `/media/backup`:

```bash
systemctl stop rsnapshot-hourly.timer rsnapshot-daily.timer rsnapshot-weekly.timer \
  rsnapshot-monthly.timer duply-laptop.timer duply-purge-laptop.timer
pgrep -a 'rsnapshot|duplicity'
```

If `pgrep` shows a run in progress, wait for it or kill it.

Dump Nextcloud with maintenance mode on:

```bash
occ() { sudo -u nextcloud php-legacy -c /etc/webapps/nextcloud/php.ini /usr/share/webapps/nextcloud/occ "$@"; }
occ maintenance:mode --on
mariadb-dump --single-transaction nextcloud > $C/nextcloud.sql
tail -1 $C/nextcloud.sql
```

The last line must read `-- Dump completed`.

Save the locally built images, then stop everything:

```bash
docker save torbox media-prod media-lists -o $C/images.tar

systemctl stop nginx php-fpm-legacy sonarr radarr readarr prowlarr calibre-web calibre-web-vegan
systemctl stop jellyfin docker-compose
(cd /opt/docker && docker compose down)
(cd /opt/immich-app && docker compose down)
docker ps
systemctl stop mariadb
```

`docker ps` must be empty before archiving, or the Immich database is copied
mid-write.

Archive. `--numeric-owner` matters for `/opt`, where the Immich database and the
WireGuard config belong to uids that only exist inside containers:

```bash
t() { tar --numeric-owner -cpf "$C/$1.tar" -C "$2" "${@:3}"; }
t sonarr     /var/lib sonarr
t radarr     /var/lib radarr
t readarr    /var/lib readarr
t prowlarr   /var/lib prowlarr
t nzbget     /var/lib nzbget
t nc-data    /var/lib/nextcloud data
t nc-apps    /var/lib/nextcloud/apps gpoddersync
t calibre    /usr/lib/calibre-web app.db gdrive.db vegan.db
t opt        /opt docker immich-app
t ssh-keys   /etc/ssh ssh_host_ed25519_key ssh_host_ed25519_key.pub ssh_host_rsa_key ssh_host_rsa_key.pub
t etc        / etc
tar --numeric-owner -cpf $C/home.tar -C /home --exclude=igray/.cache igray
cp -a /etc/webapps/nextcloud/config/config.php $C/config.php
ls -lh $C
```

`etc.tar` is reference only: the old unit files, `privado.cred`, the duply keys
and anything else you later realize you need.

### Optional: rollback image

There is no way back once the NVMe is formatted unless you take this. It is
about 40 GB and several minutes:

```bash
tar --numeric-owner --one-file-system -cpf $C/arch-root.tar \
  --exclude=./var/lib/docker --exclude=./home/igray/.cache -C / .
tar --numeric-owner -cpf $C/arch-boot.tar -C /boot .
```

Restoring it means booting an Arch ISO, recreating the two partitions,
extracting both archives and reinstalling the bootloader.

Shut down:

```bash
poweroff
```

## 3. Install NixOS

Boot the USB stick. At the console, set a password so the rest can be done over
SSH from the laptop:

```bash
passwd
```

From the laptop (the address is the same DHCP reservation; the host key is the
installer's, hence the options):

```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nixos@192.168.86.10
sudo -i
```

Check which disk is which. The target is the 931.5G `WD Blue SN570`; the 10.9T
and 3.6T disks are the arrays and must not appear in any command below:

```bash
lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE
```

Partition and format. The labels are what `hosts/server/hardware-configuration.nix`
mounts:

```bash
D=/dev/nvme0n1
wipefs -a $D
parted $D -- mklabel gpt
parted $D -- mkpart ESP fat32 1MiB 1GiB
parted $D -- set 1 esp on
parted $D -- mkpart root ext4 1GiB 100%
mkfs.fat -F 32 -n BOOT ${D}p1
mkfs.ext4 -L nixos ${D}p2
```

Mount the new root, and the backup array read-only inside it:

```bash
mount /dev/disk/by-label/nixos /mnt
mount --mkdir -o umask=077 /dev/disk/by-label/BOOT /mnt/boot
mkdir -p /mnt/media/backup /mnt/media/media
mount -o ro /dev/disk/by-uuid/069a426b-23a1-4c3f-9362-062b892cea9e /mnt/media/backup
C=/mnt/media/backup/cutover
ls $C
```

If the by-uuid path is missing, the installer has not assembled the arrays; run
`mdadm --assemble --scan` and retry.

Compare the detected hardware against the hand-written file. The kernel module
lists should agree; ignore the differing device paths:

```bash
nixos-generate-config --root /mnt --show-hardware-config
```

Restore the SSH host keys before installing so the machine keeps its identity:

```bash
mkdir -p /mnt/etc/ssh
tar --numeric-owner -xpf $C/ssh-keys.tar -C /mnt/etc/ssh
```

Copy the repo over from the laptop (second terminal):

```bash
rsync -a --exclude result --exclude .worktrees -e 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' \
  ~/Work/dotfiles nixos@192.168.86.10:/tmp/
```

Install. It asks for a root password at the end:

```bash
nixos-install --flake /tmp/dotfiles#server
```

## 4. Restore state before the first boot

Still in the installer, as root:

```bash
x() { mkdir -p "$2" && tar --numeric-owner -xpf "$C/$1.tar" -C "$2"; }
x sonarr   /mnt/var/lib
x radarr   /mnt/var/lib
x readarr  /mnt/var/lib
x nzbget   /mnt/var/lib
x opt      /mnt/opt
x home     /mnt/home
x nc-data  /mnt/var/lib/nextcloud
x nc-apps  /mnt/var/lib/nextcloud/store-apps
x calibre  /mnt/var/lib/calibre-web

mkdir -m 700 -p /mnt/var/lib/private
x prowlarr /mnt/var/lib/private

mkdir -p /mnt/var/lib/calibre-web-vegan
mv /mnt/var/lib/calibre-web/vegan.db /mnt/var/lib/calibre-web-vegan/app.db
cp -a /mnt/var/lib/calibre-web/gdrive.db /mnt/var/lib/calibre-web-vegan/

mkdir -p /mnt/var/lib/nextcloud/config
cp $C/config.php /mnt/var/lib/nextcloud/config/config.php
sed -i "s/'maintenance' => true/'maintenance' => false/" /mnt/var/lib/nextcloud/config/config.php
grep maintenance /mnt/var/lib/nextcloud/config/config.php
```

Two things here are easy to get wrong:

- Nothing may be restored to `/var/lib/nextcloud/apps`. The NixOS setup unit
  deletes that directory on every start.
- `config.php` must say `'maintenance' => false`. The setup unit refuses to run
  while maintenance mode is on.

Fix ownership and set your password inside the new system. The service uids are
different from Arch's, and NixOS does not give `igray` passwordless sudo:

```bash
nixos-enter --root /mnt
getent passwd sonarr radarr readarr nextcloud calibre-web
chown -R sonarr:media /var/lib/sonarr
chown -R radarr:media /var/lib/radarr
chown -R readarr:media /var/lib/readarr
chown -R nextcloud:nextcloud /var/lib/nextcloud
chown -R calibre-web:calibre-web /var/lib/calibre-web /var/lib/calibre-web-vegan
passwd igray
exit
```

`getent` must print five lines. If a user is missing, the install did not
finish; do not continue.

Reboot:

```bash
umount -R /mnt
reboot
```

Remove the USB stick.

## 5. First boot

From the laptop. There should be no host key warning:

```bash
ssh server.lan
systemctl --failed
```

Two failures are expected at this point and are fixed below:
`nextcloud-setup.service` (its database is empty) and `compose-docker.service`
(the local images are not loaded yet). Anything else is a real problem.

Confirm the arrays came up before touching anything else:

```bash
cat /proc/mdstat
df -h /media/media /media/backup
```

Import the Nextcloud database and rerun setup:

```bash
C=/media/backup/cutover
sudo mysql nextcloud < $C/nextcloud.sql
sudo systemctl restart nextcloud-setup phpfpm-nextcloud
sudo nextcloud-occ status
sudo nextcloud-occ app:list | head -60
```

`status` should report `installed: true`, version 35.0.3 and `maintenance:
false`. Check `gpoddersync` is listed as enabled.

Load the local images and start the compose projects:

```bash
sudo docker load -i $C/images.tar
sudo systemctl restart compose-docker compose-immich
sudo docker ps --format '{{.Names}}\t{{.Status}}'
```

Twelve containers should be up. The first start pulls roughly 8 GB of images.

Check the certificates were issued:

```bash
systemctl list-units 'acme-*' --all
sudo ls /var/lib/acme
```

## 6. Verify

- [ ] `https://cloud.igster.org` logs in, files open, a sync client reconnects
- [ ] `https://photos.igster.org` shows the library (Immich)
- [ ] `https://video.igster.org` plays something (Jellyfin)
- [ ] `https://medialists.igster.org` and `https://aiostreams.igster.org` load
- [ ] Sonarr `:8989`, Radarr `:7878`, Readarr `:8787`, Prowlarr `:9696` open with
      their history intact, and each can reach its download client
- [ ] NZBGet `:6789` and Transmission `:9091` open; Transmission reports its VPN up
- [ ] calibre-web `:8083` and `:8084` list their libraries
- [ ] Music Assistant `:8095` sees its players
- [ ] An NFS client mounts `/media/media/movies` and can write
- [ ] The Samba `media` share opens as guest from another machine
- [ ] `lpstat -v` shows `officejet_5740`, and a test page prints
- [ ] The laptop's restic `work` job completes against the server
- [ ] `sensors` shows the motherboard readings
- [ ] `sudo systemctl start raid-check` then `cat /proc/mdstat` shows a check running

If the Samba guest test fails, add `"map to guest" = "Bad User";` to the global
section in `nixos/server-shares.nix`. Arch's config did not set it either, so
guest access may never have worked.

The old `/media/media` files written by Sonarr, Radarr and Readarr carry their
Arch uids. They stay usable because the directories are setgid `media` and
group-writable. If something reports a permission error, that is where to look.

## 7. Afterwards

Rebuilds run from the laptop from now on:

```bash
nixos-rebuild switch --flake .#server --target-host igray@server.lan --sudo --ask-sudo-password
```

Still open:

- RAID failure alerts. `mdadm` is configured with `MAILADDR root`, and the
  machine cannot send mail, so a failed disk is silent.
- A restic job for the state in the table at the top.
- A home-manager configuration for `igray@server`.
- Rotate the duply GPG passphrase and the Privado VPN username if the duply job
  or that VPN account is kept.

Once the server has run cleanly for a couple of weeks, delete the staging
directory. It holds the compose `.env` files, `/etc/shadow` and the duply keys
in the clear:

```bash
sudo rm -rf /media/backup/cutover
```
