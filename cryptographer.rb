require 'gpgme'

class Cryptographer
  attr_reader :password

  def initialize(password:)
    @password = password
  end

  def encrypt(message)
    crypto.encrypt(message, recipients: 'jon@garvinz.com')
  end

  def decrypt(message)
    crypto.decrypt(message)
  end

  private

  def crypto
    @crypto ||=
      GPGME::Crypto.new(armor: true,
                        password: password,
                        pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK)
                        #passphrase_callback: self.method(:fetch_passphrase))
  end

  #def fetch_passphrase(obj, uid_hint, passphrase_info, prev_was_bad, fd)
  #  $stderr.write("Passphrase for #{uid_hint}: ")
  #  $stderr.flush
  #  begin
  #    system('stty -echo')
  #    io = IO.for_fd(fd, 'w')
  #    io.puts(gets)
  #    io.flush
  #  ensure
  #    (0 ... $_.length).each do |i| $_[i] = ?0 end if $_
  #    system('stty echo')
  #  end
  #  $stderr.puts
  #end
end
