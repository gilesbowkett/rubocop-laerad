#!/usr/bin/env ruby

require "shellwords"

input = $stdin.readlines
exit_status = input.last.to_i

# map Pronto severity levels to GitHub annotation levels
severities = {
  "I" => "notice",  # info
  "W" => "warning", # warning
  "E" => "error",   # error
  "F" => "error"    # fatal
}

# Pronto text format: path:line LEVEL: message
pronto_format = /
  (?<file>[^:]+):
  (?<line>\d+)\s
  (?<severity>[IWEF]):\s
  (?<message>.+)
/x

annotations = input.filter_map do |line|
  next unless (attrs = line.match(pronto_format))
  next if severities[attrs[:severity]] == "notice"

  "::#{severities[attrs[:severity]]} " \
    "file=#{attrs[:file]}," \
    "line=#{attrs[:line]}," \
    "title=Single-Use Variables::" \
    "#{attrs[:message]}"
end

if exit_status != 0
  annotations.each{ system("echo #{Shellwords.escape(it)}") }

  exit exit_status
end
