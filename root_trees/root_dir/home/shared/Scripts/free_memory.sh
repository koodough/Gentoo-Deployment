echo -e "\033[36mMemory before\033[0m"
free -m
sudo sync
sudo echo 3 | sudo tee /proc/sys/vm/drop_caches
echo -e "\033[32mMemory after :)\033[0m"
free -m
