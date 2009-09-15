require 'thread'
# require 'rubyamf'
require 'ffi'
require 'ffi/tools/const_generator'
require 'stringio'

# ipcs -a

class LocalConnection
  class Semaphore
    module Const
      eval(FFI::ConstGenerator.new(nil, :required => true) do |gen|
        gen.include 'semaphore.h'
        gen.include 'sys/types.h'
        gen.include 'sys/stat.h'
        gen.include 'fcntl.h'
        gen.const 'O_CREAT'
        gen.const 'S_IRUSR'
        gen.const 'S_IWUSR'
        gen.const 'S_IRGRP'
        gen.const 'S_IWGRP'
        gen.const 'S_IROTH'
        gen.const 'S_IWOTH'
      end.to_ruby)
    end
    include Const
    
    extend FFI::Library
    typedef :int, :mode_t
    attach_function :sem_open,   [ :string, :int, :mode_t, :uint ], :pointer
    attach_function :sem_wait,   [ :pointer ], :int
    attach_function :sem_post,   [ :pointer ], :int
    attach_function :sem_close,  [ :pointer ], :int
    
    attr_reader :pointer
    def initialize(name)
      @pointer = sem_open(name, O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH, 10) # 0666
      @pointer = FFI::AutoPointer.new(@pointer, self.class.method(:release))
    end
    
    def syncronize(&block)
      sem_wait(@pointer)
      yield
      sem_post(@pointer)
    end
    
    def self.release(p)
      sem_close(p)
    end
  end
  
  class SharedMemory
    module Const
      eval(FFI::ConstGenerator.new(nil, :required => true) do |gen|
        gen.include 'sys/ipc.h'
        gen.const 'IPC_CREAT'
      end.to_ruby)
    end
    include Const
    
    extend FFI::Library
    typedef :int, :key_t
    attach_function :shmget, [ :key_t, :int, :int ], :int
    attach_function :shmat,  [ :int, :pointer, :int ], :pointer
    attach_function :shmdt,  [ :pointer ], :int
    
    attr_reader :shmid, :pointer
    def initialize(key, size)
      puts FFI.errno
      @shmid   = shmget(key, size, 0666 | IPC_CREAT)
      puts FFI.errno
      ObjectSpace.define_finalizer(self, self.class.finalize(@shmid))
      @pointer = shmat(@shmid, nil, 0)
      puts FFI.errno
    end
    
    def write(data)
      @pointer.write_string(data)
    end
    
    def read(size)
      @pointer.read_string_length(size)
    end
    
    def self.finalize(shmid)
      Proc.new { |*args| shmdt(shmid) }
    end
  end
  
  SHM_SIZE = 64528
  SHM_HEADER_OFFSET = 40976
  
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
    Thread.new do
      while @running
        poll
        sleep 0.1
      end
    end
  end
  
  def disconnect
    @running = false
  end
  
  private
    def poll
      # Lock
      # Check shared memory
      # Execute callbacks if result
      # Write messages
      syncronize {
        
      }
    end
    
    def shared_memory
      @sm ||= SharedMemory.new(0x53414E44, SHM_SIZE)
    end
    
    def read_memory
      StringIO.new(shared_memory.read(SHM_SIZE))
    end
    
    def syncronize(&block)
      @sem ||= Semaphore.new("MacromediaSemaphoreDig")
      @sem.syncronize(&block)
    end
end
