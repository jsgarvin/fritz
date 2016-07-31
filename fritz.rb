require './irc_adapter'
require './cryptographer'
require 'forwardable'

class Fritz
  extend Forwardable
  attr_reader :adapter, :password
  def_delegators :cryptographer, :encrypt, :decrypt

  def initialize(password:)
    @password = password
    @adapter ||= IrcAdapter.new(nick: name,
                                channel: '#friznit',
                                receiver: receiver)
  end

  def send(message)
    adapter.send(encrypt(message))
  end

  private

  def cryptographer
    @cryptographer ||= Cryptographer.new(password: password)
  end

  def receiver
    @receiver ||= lambda do |message|
      puts "Received: #{message.inspect}"
      puts "Decrypted: #{decrypt(message)}"
    end
  end

  def name
    @name ||= "bot#{rand_string(16)}"
  end

  def rand_string(length)
    (0...length).map { (65 + rand(26)).chr }.join
  end
end
