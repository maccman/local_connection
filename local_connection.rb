require 'thread'
# require 'rubyamf'

class LocalConnection
  attr_reader :running, :name
  
  def initialize(name, &block)
    @name     = name
    @callback = block
    @running  = false
    @messages = []
  end
  
  def write(ob)
    raise "Connect first" unless running
    @messages << ob
  end
  
  def connect
    @running = true
    register
    Thread.new do
      while @running
        poll
        sleep 0.1
      end
    end
  end
  
  def disconnect
    @running = false
    deregister
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
      # Lock
      # Check shared memory
      # Execute callbacks if result
      sync {
        
      }
    end
    
    def shared_memory
      @shared_memory ||= begin
        sm = SysVIPC::SharedMemory.new( 0x53414E44, 0 )
        sm.attach
        sm
      end
    end
    
    def read_memory
      
    end
    
    def sync(&block)
      @sem ||= begin
        SysVIPC::Semaphore.new(
          "MacromediaSemaphoreDig", 
          1, 
          SysVIPC::IPC_CREAT | 0600
        )
      end
      @sem.lock { yield }
    end
end