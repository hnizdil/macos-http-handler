#  HTTPHandler for macOS

This application registers itself as system HTTP(S) handler.
On every open URL request, it consults config and uses configured browser.

Browser is opened with `/usr/bin/open -a <application> <url>` command.

URL patterns are regular expressions.
