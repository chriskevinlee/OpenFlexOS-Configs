# remove  orphaned packages
#sudo pacman -Rns $(pacman -Qdtq)

# remove cached packages: keep 3 versions of installed packages and remove  any cached packages that have been uninstalled
#sudo paccache -ru


#sudo pacman -Scc

# keeps log files for 2 weeks, deletes everything before it
#sudo journalctl --vacuum-time=2weeks
