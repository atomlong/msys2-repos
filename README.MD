MSYS2 Eyun Community Repository
# msys2-repos
### Usage

(1) Add repo:

```
[eyun]
SigLevel = Never
Server = https://efiles.cf/api/raw/?path=/msys2/$arch/$repo
```
to your /etc/pacman.conf .

(2) Import PGP Keys:
```
sudo pacman -Syy && sudo pacman -S eyun-keyring
```

(3) Remove 'SigLevel' or change it to other value
```
sudo sed -i -r '/^\[eyun]/,/^\[\w+]/{/^SigLevel\s*=.*/d}' /etc/pacman.conf
```
