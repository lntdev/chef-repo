name "sawtooth_setup"

description "Sets up operating systems basics for sawtooth"
run_list "recipe[motd]","recipe[ufw]"
