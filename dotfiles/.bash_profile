test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
if [ -e /home/jpaugh/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/jpaugh/.nix-profile/etc/profile.d/nix.sh;
fi # added by Nix installer
