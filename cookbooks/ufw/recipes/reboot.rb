reboot 'now' do
  action :request_reboot
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 2
end

