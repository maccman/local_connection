require 'thread'
# require 'rubyamf'

class LocalConnection
  def initialize(name, &block)
    @name = name
    @callback = block
  end
  
  def connect
    
  end
  
  def disconnect
    
  end
  
  private
    def register
      sync {
        
      }
    end
    
    def deregister
      sync {
        
      }
    end
  
    def poll
      
    end
    
    def sync(&block)
      
    end
end