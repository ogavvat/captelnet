#!/usr/local/bin/ruby

require "telnetlib"
require "logger"
require "yaml"


logger = Logger.new("captelnet.log")
logger.formatter = Logger::Formatter.new
logger.info("----")
logger.info("#{$PROGRAM_NAME} #{$ARGV.inspect}")


if ARGV.size != 2
  $stderr.puts("
USAGE:
  captelnet.rb (hostsfile) (cmdfile);

")
  exit
  
end

hostfile = ARGV[0]
cmdfile = ARGV[1]


# ホストファイル読み出し
hostlist = loadHost(hostfile)


# ホストごとにtelnet経由でコマンド実行
hostlist.each { |hostconfig|

  logger.info(hostconfig)
  begin  
    host = hostconfig["host"]
    user = hostconfig["user"]
    password = hostconfig["password"]
    logger.info("host: #{host}, user: #{user}, password: #{password}")
    puts("host: #{host}, user: #{user}, password: #{password}")

    # Telnet接続
    telnet = telnetLogin(host, user, password)
    if telnet
      puts "telnet logined."
      cmdExec(logger, telnet, host, cmdfile)
      telnetLogout(telnet)
    end

  rescue
    logger.info("Error: #{$!} at #{$@}")
    puts("Error: #{$!} at #{$@}")
    next
  end

}

