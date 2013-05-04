
Weblog is a browser for system log files. It treats log messages as ordered
text tuples, where certain formatting conventions are adhered to:

* The timestamp is the first field of the message and it is an RFC 3339 (or
  ISO 8601) formatted time and date with no spaces.

* There is DNS hostname, representing a server or "network location".

* There is an "application" or "component" field.

Together, these three fields locate each message in a browsable, zoomable 3D
space of logs. Here's an example of a consumable log message:

    2011-04-09T11:31:21.222222+00 a.server user.err apache[678]: webs active

It is not hard to get `rsyslog` to format messages exactly this way:

    $template Log, "%timereported:::date-rfc3339% \
                    %hostname% \
                    %syslogfacility-text%.%syslogpriority-text% \
                    %syslogtag%\
                    %msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n"
    $ActionFileDefaultTemplate Log

Why strings, even for timestamps? Well, not-parsing is faster than parsing...

