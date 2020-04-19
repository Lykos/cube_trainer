# frozen_string_literal: true

require 'etc'

module OsHelper
  def self.os_user
    Etc.getlogin
  end

  def self.hostname
    `hostname`.chomp
  end

  # Lol, don't worry, this is not the prod password,
  # but I needed to bootstrap users somehow.
  def self.default_password
    'abc123'
  end
end
