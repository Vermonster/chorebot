Dir.glob("#{File.dirname(__FILE__)}/schedulings/*.rb").each(&method(:require))
