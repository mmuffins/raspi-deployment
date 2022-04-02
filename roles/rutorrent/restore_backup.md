# Download the backup that should be restored

# stop container
cd ~/docker/rutorrent
docker-compose down

# move old directories
cd ~
sudo mv data data_old
#Optional: 
sudo mv passwd passwd_old
sudo mv torrents torrents_old

# create restore directory
cd ~
mkdir restore

# unzip files while preserving permissions
cd ~
#bunzip2 [bz2_name_here]
#sudo tar xpf [tarname_here] -C ~/restore
sudo chown -R $USER:$USER ~/restore

# Move backed up folders
cd ~
mv ~/restore/home/<backupuser>/data .
#Optional: 
mv ~/restore/home/<backupuser>/torrents .
mv ~/restore/home/<backupuser>/passwd .

# start container
cd ~/docker/rutorrent
docker-compose up -d

# check logs to ensure not errors are thrown during startup
docker logs rutorrent

# Remove old data
cd ~
sudo rm [tarname_here]
sudo rm -r ~/restore
sudo rm -rf ~/data_old
sudo rm -rf ~/passwd_old
sudo rm -r ~/torrents_old