# ZoneCheck

This is a simple Ruby script that takes input about a DNS zone from a YAML file
and outputs a pleasantly formatted diff between two DNS servers. Useful for
migrating DNS records manually, where it's easy to make a mistake.

# Usage

Create a `.yml` file somewhere by copying zone.yml.template. Edit the template
accordingly, and then run

```
./zonecheck.rb <zonefile>.yml
```

