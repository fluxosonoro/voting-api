# coding: utf-8
ENV['RACK_ENV'] = 'development'

require "rubygems"
require 'api'
require 'models'


class Executor
    def app
        Sinatra::Application
    end
    def reindex(*args)
        Sunspot.remove_all!(Bill)
        Sunspot.index!(Bill.all)

    end
end
ARGV.delete_if {|element| element.strip.empty? }

ejecutor = Executor.new
command = ARGV[0]
arguments = Array.new
for i in 1..ARGV.length-1 
    arguments.push "'"+ARGV[i]+"'"
end
if ejecutor.methods.include? command
    line = "ejecutor."+command+ " "+ arguments.join(", ")
    eval line
else
    p "tenis puro frio, escribe un comando que funcione"
end


ARGV.each do|a|
  
end