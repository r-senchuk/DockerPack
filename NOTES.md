

Resetting DNS cache on OSX

# Yosemite v10.10.4:
sudo killall -HUP mDNSResponder

# Yosemite v10.10 through v10.10.3:
sudo discoveryutil mdnsflushcache

# OS X Mavericks, Mountain Lion, and Lion
sudo killall -HUP mDNSResponder

# Mac OS X v10.6
sudo dscacheutil -flushcache

