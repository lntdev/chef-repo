name "useradd"

description "Sets up user rundeck"
run_list "recipe[ufw::user]"
