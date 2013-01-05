# encoding: UTF-8

require 'rubygems'
require 'subexec'


#日志处理
class LogFile
  class << self
    def params_escape(params)
      #params.gsub!()
    end
    
    def run_cmd(cmd)
      Rails.logger.debug { "run cmd: #{cmd}" } if defined?(Rails)
      sub = Subexec.run cmd,timeout:60
      sub.output
    end
    #参数
    #linenum:20
    def tail(file_name,opts = {})
      cmd = [compressed_file(file_name)]
      cmd << %Q~tail -n #{opts.fetch(:linenum,20)}~
      return yield run_cmd(cmd.join).split(/\n/) if block_given?
      run_cmd(cmd.join).split(/\n/)
    end
    
    #参数
    #linenum:20
    #before:0 关键字前几行
    #after:0 关键字后几行
    #regx:过滤条件
    def egrep(file_name,opts ={} )
      cmd = [compressed_file(file_name)]
      regx = opts.fetch(:regx,'').clone
      before = opts.fetch(:before,0).to_i
      after = opts.fetch(:after,0).to_i
      regx.gsub!(/'|"/,'')
      regx.gsub!(/\s/,'\s')
      regx.gsub!(/\[/,'\[')
      regx.gsub!(/\]/,'\]')
      cmd << %Q~egrep -A #{after} -B #{before} -n -i -E '#{regx}' | ~
      cmd << %Q~tail -n #{opts.fetch(:linenum,20)}~
      return yield run_cmd(cmd.join).split(/\n/) if block_given?
      run_cmd(cmd.join).split(/\n/)
    end
    
    #压缩文件处理
    #
    def compressed_file(file_name)
      case 
      when file_name =~ /tar\.gz$/ then "gunzip -c '#{file_name}' | tar Oxf - | "
      when file_name =~ /gz$/ then "gunzip -c '#{file_name}' | "
      when file_name =~ /bz2/ then "bunzip2 -c '#{file_name}' | "
      else
        "cat '#{file_name}' | "
      end
    end
    
  end
end

if $0 == __FILE__
  LogFile.egrep('/tmp/production.log',linenum:10,regx:'95db783c69d4a5f94f022e4c882da80b'){|line|
    puts line
  }
end
