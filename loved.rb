#!/usr/bin/env ruby
require 'rubygems'
require 'librmpd'
require 'yaml'
require 'iconv'

class MPD
  alias_method :orig_add, :add

  def add(file)
    orig_add(file)
  rescue => error
    return false if error.message =~ /add: directory or file not found/
    raise error
  end

  class Song
    def to_s
      "#{artist} - #{title}" + \
        ("\n   tags: #{tags.join(' ')}" if tags.any?).to_s
    end
  end
end

module Loved
  extend self

  class NoCurrentSong < ArgumentError; end

  @@auto_tags = %w(artist genre date)

  def playlists_directory=(directory)
    @@directory = directory
    FileUtils.mkdir_p(@@directory) unless File.directory?(@@directory)
  end

  def mpd
    @mpd ||= MPD.new.tap { |mpd| mpd.connect }
  end

  def love_current_mpd_song!(tags=[])
    raise NoCurrentSong unless song = mpd.current_song
    love_it!(song, tags)
  end

  def append_found_songs_to_mpd_playlist!(tags=[])
    by_tags(tags).tap do |songs|
      songs.each do |song|
        puts "Skipped #{song} (file not found)" unless mpd.add(song)
      end
    end
  end

  def love_it!(song, tags=[])
    auto_tags = @@auto_tags.map { |key| song[key] }.compact
    song.tags = tags + auto_tags

    write_to_database(song)

    song
  end

  def loved?(song, tags=[])
    by_tags(tags).include?(song.file)
  end

  def all
    by_tags(['all'])
  end

  def by_tags(tags=[])
    files = tags.map! { |tag| file_name_for_tag(tag) }

    case tags.length
    when 0 then all
    when 1 then find_songs_in_file(files.first)
    else
      files.inject([]) do |songs, file|
        songs << find_songs_in_file(file)
      end
    end
  end

  private
    def write_to_database(song)
      song.tags.uniq!
      song.tags.map! { |tag| normalize_tag(tag) }

      files = song.tags.dup.push('all').map { |tag| file_name_for_tag(tag) }
      files.each do |file_name|
        File.open(file_name, 'a+') do |file|
          next if file.readlines.map(&:chomp).include?(song.file)
          file.puts song.file
        end
      end

      song
    end

    def find_songs_in_file(file_name)
      File.readlines(file_name).map(&:chomp)
    rescue Errno::ENOENT
      []
    end

    def file_name_for_tag(tag)
      File.join(@@directory, normalize_tag(tag))
    end

    # thanks technoweenie!
    def normalize_tag(tag)
      result = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', tag.to_s).to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
      result.downcase!
      result
    end
end

if $0 == __FILE__
  Loved.playlists_directory = File.join(ENV['HOME'], '.loved')

  if ARGV.delete('play')
    songs = Loved.append_found_songs_to_mpd_playlist!(ARGV)
    puts "Appended #{songs.length} song#{'s' if songs.length > 1} to your MPD playlist. Enjoy!"
    exit
  elsif ARGV.delete('list')
    Loved.by_tags(ARGV).each { |song| puts song } && exit
  end

  begin
    song = Loved.love_current_mpd_song!(ARGV.dup)
    puts "Loved #{song}"
  rescue SocketError, Errno::ECONNREFUSED
    abort "Couldn't connect to MPD"
  rescue Loved::NoCurrentSong
    abort "Couldn't determine current song. Check that MPD is playing."
  end
end
