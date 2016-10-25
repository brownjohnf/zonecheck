#!/usr/bin/env ruby

require "yaml"
require "rainbow"

config = YAML.load(File.read(ARGV[0]))
raise ArgumentError, "You must pass exactly 2 nameservers!" if config["nameservers"].length != 2
domain = config["domain"]
ns1, ns2 = config["nameservers"]

results = {}
config["records"].keys.each do |key|
  results[key] ||= {}
end

config["records"].each_pair do |type, subdomains|
  subdomains.each do |subdomain|
    fqdn = [ subdomain, domain ].compact.join(".")

    config["nameservers"].each do |ns|
      cmd = "dig @%s %s %s" % [
        ns,
        fqdn,
        type.upcase,
      ]
      #puts cmd

      res = `#{cmd}`
      print = false
      out = []

      res.split("\n").each do |line|
        print = false if line == ""
        out << line if print && line =~ /#{type.upcase}/
        print = true if line =~ /;; ANSWER/
      end
      out.sort!

      #out = [out.first] if type == :cname

      results[type][fqdn] ||= {}
      results[type][fqdn][ns] = out.join("\n")
    end
  end
end

results.each_pair do |type, fqdn|
  fqdn.each_pair do |domain, data|
    color = :green
    color = :red if data[ns1].split("\t").last != data[ns2].split("\t").last

    puts "%s\t@%s\n%s\n%s\t@%s\n%s\n\n" % [
      domain,
      data.keys.first,
      Rainbow(data.values.first).fg(color),
      domain,
      data.keys.last,
      Rainbow(data.values.last).fg(color),
    ]
  end
end

