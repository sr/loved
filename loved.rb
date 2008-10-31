#!/usr/bin/env ruby
require 'rubygems'
require 'librmpd'
require 'yaml'
require 'iconv'

class Hash
  def keep(keys)
    inject({}) do |hash, (key, value)|
      hash[key] = value if keys.include?(key)
      hash
    end
  end
end

class MPD
  class Song
    def to_s
      string = "#{artist} - #{title}"
      string << "\n   tags: #{tags.join(' ')}" if tags.any?
      string
    end
  end
end

class MPDIsNotPlayingError < StandardError; end
class AlreadyLovedError < StandardError; end

class Loved
  class << self
    def default_configuration
      { :play_lists_directory => File.join(ENV['HOME'], '.favorites'),
        :mpd_address   => 'localhost:6600', 
        :auto_tag_with => %w(artist genre date) }
    end

    def default_configuration_file
      File.join(ENV['HOME'], '.favorites-rc')
    end

    def playing_song(tags=[], config_file=default_configuration_file)
      song = new(config_file).love_playing_song(tags)
      puts "=> Loved #{song.to_s}"
    rescue AlreadyLovedError
      abort 'Already loved, fool!'
    rescue MPDIsNotPlayingError, Errno::ECONNREFUSED
      abort "MPD ain't playing, fool!"
    end

    def play(tags, config_file=default_configuration_file)
      songs = new(config_file).play(tags)

      puts "Added #{songs.length} songs to your play list. Enjoy!"
    end
  end

  def initialize(configuration_file)
    @configuration_file = configuration_file
    ensure_play_lists_directory_exists!
  end

  def love_playing_song(tags=[])
    raise MPDIsNotPlayingError unless mpd.playing?
    love_it(mpd.current_song, tags)
  end

  def play(tags=[])
    songs = find_by_tags(tags)
    songs.each { |song| mpd.add(song) }

    songs
  end

  def love_it(song, tags=[])
    raise ArgumentError unless song.file
    raise AlreadyLovedError if loved?(song)
    auto_tags = song.keep(configuration[:auto_tag_with]).values
    song.tags = tags.uniq.push(*auto_tags).map! { |tag| %Q{"#{tag}"} }
    raise AlreadyLovedError if loved?(song)
    write_to_database(tags) { "#{song.file} # #{song.tags.join(' ')}" }

    song
  end

  def loved?(song, tags=[])
    find_by_tags(tags).include?(song.file)
  end

  def find_all
    find_songs_in_file('all')
  end

  def find_by_tags(tags=[])
    case tags.length
    when 0 then find_all
    when 1 then find_songs_in_file(file_name_for_tag(tags.first))
    else
      tags.inject([]) do |songs, tag|
        songs.push(find_songs_in_file(file_name_for_tag(tags.first)))
      end
    end
  end

  def configuration
    @configuration ||= self.class.default_configuration.merge(load_configuration_file)
  end

  private
    def write_to_database(tags, &block)
      tags.push('all')
      files = tags.map { |tag| file_name_for_tag(tag) }
      files.each do |file_name|
        File.open(file_name, 'a') { |f| f.puts "#{yield}\n" }
      end
    end

    def find_songs_in_file(file_name)
      File.foreach(file_name_for_tag('all')).inject([]) do |songs, line|
        songs.push(line.split('#').first.strip)
      end
    rescue Errno::ENOENT
      []
    end

    def file_name_for_tag(tag)
      File.join(configuration[:play_lists_directory], normalize_tag_for_file_name(tag))
    end

    # thanks technoweenie!
    def normalize_tag_for_file_name(tag)
      result = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', tag.to_s).to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
      result.downcase!
      result
    end

    def ensure_play_lists_directory_exists!
      unless File.directory?(configuration[:play_lists_directory])
        puts "Creating play lists directory"
        FileUtils.mkdir_p(configuration[:play_lists_directory])
      end
    end

    def mpd
      MPD.new(*configuration[:mpd_address].split(':')).tap { |mpd| mpd.connect }
    end

    def load_configuration_file
      YAML.load_file(@configuration_file)
    rescue Errno::ENOENT
      {}
    end
end

if $0 == __FILE__
  if ARGV.join =~ /p[lay]?/
    Loved.play(ARGV[1..-1])
  else
    Loved.playing_song(ARGV)
  end
end
