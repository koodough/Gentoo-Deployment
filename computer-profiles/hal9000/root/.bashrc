
alias screen='screen -xRRA'
alias emerge='time emerge'

#Message of the Day
#cat /etc/motd

#if you want to use your home folder use $HOME
export PATH="/home/shared:/home/shared/Applications:/home/shared/Scripts:${PATH}"

function refresh-bash {
env-update && source /etc/profile;
}
