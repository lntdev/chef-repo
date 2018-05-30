#!/opt/chef/embedded/bin/ruby

###################################################################
#
# Required Ruby gems
#
###################################################################

require 'logger'
require 'json'
require 'optparse'

###################################################################
#
# Get the required options for the prechecks to run
#
###################################################################

arguments = Hash.new();

parser=OptionParser.new do |args|
  args.banner = "Usage: mapper.rb [options]"
  args.separator ""

  args.separator "Mandatory options:"

  args.on("-u", "--username ","SFDC Username ex:- -u c5234054") do |i|
    arguments[:username] = i
  end

  args.on("-p", "--password ","SFDC Password ex:- -p ******") do |i|
    arguments[:password] = i
  end

  args.on("-h", "--hostnumber ", "Hostname's host number ex:- -h 03") do |i|
    arguments[:hostnumber] = i
  end


  args.on("-r", "--rdproject ", "Rundeck project ex:- -r dc17_bizx_prod") do |i|
    arguments[:rundeckproject] = i
  end
  
  args.on("-e", "--rdexecid ", "Rundeck job execution id ex:- -e 1123") do |i|
    arguments[:rdexecid] = i
  end
  
  args.on("-j", "--json ", "json file where all the properties reside ex:- -j json_file ") do |i|
    arguments[:json] = i
  end

  args.on("-d", "--dcjson ", "json file where all dc specific properties reside ex:- -d dc_specific_json_file ") do |i|
    arguments[:dcjson] = i
  end

  args.separator ""
  args.separator "Help options:"

  args.on_tail("-h", "--help", "for usage ./mapper.rb -h|--help ") do
    puts args
    exit
  end
end

begin

  parser.parse!
  mandatory = [:username,:password,:hostnumber,:ostype,:server_type,:size,:rundeckproject,:rdexecid,:json,:dcjson]
  missing = mandatory.select{ |param| arguments[param].nil? }

  unless missing.empty?
    puts "";
    puts "Missing options: #{missing.join(', ')}"
    puts parser
    exit(1);
  end

rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts parser
  exit(1);
end

###################################################################
#
# Global variable declaration
#
###################################################################

$homeDir = File.dirname(__FILE__)
$template_compute_json = arguments[:json]
$identity_json = arguments[:dcjson]
$host_number = arguments[:hostnumber]
$rundeck_project = arguments[:rundeckproject]
$rd_execid = arguments[:rdexecid]

###################################################################
#
# Configuring logging mechanism
#
###################################################################

$log = Logger.new("/automation/#{$rundeck_project}/vmcreation_#{$rd_execid}.log")
$log.level = Logger::DEBUG

$log_std = Logger.new("| tee #{STDOUT},#{STDERR}")
$log_std.level = Logger::INFO

###################################################################
#
# Class with methods to perform operations
#
###################################################################
class Mapper
	@@dc = $rundeck_project.split("_")[0].downcase
	@@product = $rundeck_project.split("_")[1].downcase
	@@env = $rundeck_project.split("_")[2].downcase
        @@app_template_details = nil
	@@identity = nil
	def initialize()
		begin
			template_json = File.read($template_compute_json)
			@@app_template_details = JSON.parse(template_json)
			$log.info "Template computation json load and parse completed."
		rescue JSON::ParserError => e
                        $log.error "[ECODE-101] Unable to Parse template compute json or load file : #{$template_compute_json}"
			$log_std.fatal "[ECODE-101] JSON Error. Report to Automation Team with rundeck execution id #{$rd_execid}"
			exit(1)
                end
		begin
			id_json = File.read($identity_json)
			@@identity = JSON.parse(id_json)
			$log.info "Json loaded with dc specific identification"
		rescue JSON::ParserError => e
                        $log.error "[ECODE-101] Unable to Parse dc specific json or load file : #{$identity_json}"
			$log_std.fatal "[ECODE-101] JSON Error. Report to Automation Team with rundeck execution id #{$rd_execid}"
			exit(1)
                end
	end
	def identifyDC()
		dc_id = @@identity[@@dc]["identity"]
		return dc_id 
	end
	def create_hostname()
		hostname = @@app_template_details["common"]["hostname"]["env"][@@env] + @@dc.scan(/\d/).join + @@app_template_details[@@product]["applications"][$server_type]["hostname_mid"] + $host_number 
		return hostname
	end
	def monsoon()
		input_set = Hash.new
		availability_zones = @@identity[@@dc]["availability_zones"]
		find_zone = ($host_number.to_i % availability_zones.length.to_i) 
		input_set["identity"] = identifyDC
		input_set["availability_zone"] = availability_zones[find_zone]
		input_set["chef_role"] = @@app_template_details["common"]["chef_role"]
		input_set["image_type"] = @@app_template_details["common"][identifyDC]["os_mapper"][$os_type]
		input_set["cpu_ram"] = $size
		type = @@app_template_details[@@product]["applications"][$server_type]["type"]
		input_set["mount"] = @@app_template_details[@@product][type]["mount"]
		input_set["volume"] = @@app_template_details[@@product][type]["volume"]
		input_set["security_group"] = @@app_template_details[@@product]["applications"][$server_type]["security_group"]
		input_set["hostname"] = create_hostname
		input_set["local_user"] = @@app_template_details[@@product][type]["local_user"]
		begin
			File.open("/automation/#{$rundeck_project}/mapper_#{$rd_execid}.json", 'w') do |file|
				file.write(input_set.to_json)
			end
			$log_std.info "Mapper json generated successfully"
		rescue
			$log.error "Unable to open file /automation/#{$rundeck_project}/mapper_#{$rd_execid}.json"
			$log_std.fatal "[ECODE-102] JSON File missing. Report to Automation Team with rundeck execution id #{$rd_execid}"
			exit(1)
		end
	end
end

obj = Mapper.new
obj.monsoon
