# coding: utf-8
ENV['RACK_ENV'] = 'development'

require "rubygems"
require './api'
require './models'

'''
Reindex usage:
bundle exec ruby commands.rb reindex Model_Name
wnere Model_Name is the model you want to reindex (uppercase singular), like Bill or Table
'''

class Executor
    def app
        Sinatra::Application
    end
    def reindex(*args)
        #Sunspot.remove_all!(Bill)
        #Sunspot.index!(Bill.all)
        #Sunspot.remove_all!(Table)
        #Sunspot.index!(Table.all)
	model = args[0].to_s.camelize.singularize.constantize
	Sunspot.remove_all(model)
	Sunspot.index!(model.all)
    end
end
ARGV.delete_if {|element| element.strip.empty? }

ejecutor = Executor.new
command = ARGV[0]
arguments = Array.new
for i in 1..ARGV.length-1 
    arguments.push "'"+ARGV[i]+"'"
end
if ejecutor.methods.include? command.to_sym
    line = "ejecutor."+command+ " "+ arguments.join(", ")
    eval line
else
    p "tenis puro frio, escribe un comando que funcione"
    p command.methods
end


ARGV.each do|a|
  
end
