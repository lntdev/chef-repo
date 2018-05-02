name "motd_setup"

description "Sets up motd for servers"
run_list "recipe[motd]","recipe[ufw]"
