Dir.glob("#{File.dirname(__FILE__)}/chores/*.rb").each(&method(:require))
