
require "net/telnet"


def telnetLogin(host,user,password)

  begin
    telnet = Net::Telnet.new("Host" => host, "Prompt" => /[$%#>*] \z/n)
    telnet.login(user, password)
  #rescue Timeout::Error
  rescue
    return nil
  end

  return telnet
end


def telnetExecCommand(logger, telnet, cmd)
  begin 
    result = telnet.cmd(cmd)
  rescue Timeout::Error => e
    logger.info("command time out")
    puts "command time out"
    return nil
  else
    return result
  end
end

def telnetExecWaitfor(logger, telnet, cmd, waitfor)
  begin 
    result = telnet.cmd("String"=>cmd, "Match"=>/#{waitfor}/)
  rescue Timeout::Error => e
    logger.info("command time out")
    puts "command time out"
    return nil
  else
    return result
  end
end


def telnetLogout(telnet)
  telnet.cmd("logout")
  telnet.close
end



# telnet接続先へコマンド実行
def cmdExec(logger, telnet, host, cmdfile)
  begin
    cmdconfigs = YAML.load_file(cmdfile)  
  rescue
    logger.info("Error: #{$!} at #{$@}")
    puts("Error: #{$!} at #{$@}")
    exit
  else
  end

  cmdconfigs.each {|cmdconfig|
    logger.info(cmdconfig)
    cmd = cmdconfig["cmd"]
    wait = cmdconfig["wait"]
    waitfor = cmdconfig["waitfor"]
    savefile = cmdconfig["savefile"]

    logger.info("host: #{host}, cmd: #{cmd}, wait: #{wait}, waitfor: #{waitfor}, savefile: #{savefile}")
    puts("host: #{host}, cmd: #{cmd}, wait: #{wait}, waitfor: #{waitfor}, savefile: #{savefile}")

    if waitfor && cmd
      result = telnetExecWaitfor(logger, telnet, cmd,waitfor)
      logger.info(result)
      puts result
    elsif cmd
      result = telnetExecCommand(logger, telnet, cmd)
      logger.info(result)
      puts result
    end

    if wait
      sleep wait
    end

    if savefile
      outfile = File.new("#{host}_#{savefile}","a")
      outfile.puts(result)
    end  
  }

end


# ホストファイル読み出し
def loadHost(hostfile)
  begin
    hostlist = YAML.load_file(hostfile)  
  rescue
    logger.info("Error: #{$!} at #{$@}")
    puts("Error: #{$!} at #{$@}")
    return nil
  else
  end
  
  return hostlist
end
