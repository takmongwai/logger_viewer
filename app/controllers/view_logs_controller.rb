# encoding: UTF-8

class ViewLogsController < ApplicationController
  
  #列出所有的日志目录
  def index
  end
  
  
  #显示特定目录下的所有日志
  def dir
    @log_dir = File.expand_path(params[:logdir])
    raise RuntimeError.new("非法操作") unless LOG_DIR.include?(@log_dir)
    @log_files = Dir.glob(File.join(@log_dir,"**"))
  end
  
  #显示日志
  def log_file
    line = params[:line] || 20
    @grep = params[:grep]
    @line = line.to_i >= 200 ? 200 : line.to_i
    @log_dir = params[:logdir]
    @log_file = params[:logfile]
    @after = params[:after].to_i || 0
    @before = params[:before].to_i || 0
    if @grep.to_s.strip.size > 0
      @log_lines = LogFile.egrep(@log_file,linenum:@line,regx:@grep,after:@after,before:@before)
    else
      @log_lines = LogFile.tail(@log_file,linenum:@line)
    end
  end
  
end
