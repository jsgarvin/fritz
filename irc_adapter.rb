require 'cinch'

class IrcAdapter
  attr_reader :cinchbot, :channel, :receiver

  def initialize(nick:, channel:, receiver:, server: 'irc.freenode.org')
    @channel = channel
    @receiver = receiver
    @cinchbot = Cinch::Bot.new do
      configure do |c|
        c.server = server
        c.channels = [channel]
        c.nick = nick
      end

      on :message do |line|
        begin
          @pgp_messages ||=  Hash.new([])
          @pgp_messages[line.user] = '' if line.message =~ /^-----BEGIN<SP>PGP<SP>MESSAGE-----/
          @pgp_messages[line.user] << line.message
          puts "COLLECTED: #{line.message}"
          if @pgp_messages[line.user] =~ /-----END<SP>PGP<SP>MESSAGE-----<BR>$/
            @pgp_messages[line.user].gsub!(/\<SP\>/, ' ').gsub!(/<BR>/, "\n")
            receiver.call(@pgp_messages[line.user])
          end
        rescue => e
          puts e.inspect
          raise e
        end
      end

    end
    cinchbot.loggers = Cinch::LoggerList.new #STFU
    Thread.new { cinchbot.start }
    sleep 1 until (cinchbot.irc and cinchbot.irc.registered?)
  end

  def send(message)
    puts "Sending:\n#{message.to_s}"
    puts "Marked: #{mark_special_characters(message.to_s)}"
    puts "SplitUp: \n#{split_up(mark_special_characters(message.to_s))}"
    target.send(split_up(mark_special_characters(message.to_s)))
  end

  private

  def mark_special_characters(message)
    message.gsub(/\n/, '<BR>').gsub(/ /, '<SP>')
  end

  def split_up(message)
    message.scan(/.{1,384}/).join("\n")
  end

  def target
    @target ||= Cinch::Target.new(channel, cinchbot)
  end
end
