Collectdsocket
==============

`collectdsocket` is an [Mcollective](http://puppetlabs.com/mcollective) plugin written to interface with the local collectd unix socket connection on a node. This allows us to ask all nodes for the value of a specific metric. It also allows for the ability to alert on thresholds relative to the entire collective for use in things like Nagios.

Collectd socket configuration
-----------------------------
The socket information is created and written to by the following collectd plugin configuration as [outlined here](http://collectd.org/documentation/manpages/collectd-unixsock.5.shtml)


```
LoadPlugin unixsock
<Plugin unixsock>
  SocketFile "/opt/collectd/var/run/collectd-unixsock"
  SocketGroup "root"
  SocketPerms "0770"
</Plugin>
```

The default location for the socket file is ``/opt/collectd/var/run/collectd-unixsock`` but can be configured in the mcollective server config with the following:

```
plugin.collectdsocket.socketpath = /path/to/socket
```

You can use the `collectdctl` utility to interface with the local socket. It has a few modes to gather information with:

**listval**:

```
/opt/collectd/bin/collectdctl listval
boi.a1501/apache-local/apache_scoreboard-sending
boi.a1501/apache-local/apache_scoreboard-starting
boi.a1501/apache-local/apache_scoreboard-waiting
boi.a1501/cpu-0/cpu-idle
boi.a1501/cpu-0/cpu-interrupt
boi.a1501/cpu-0/cpu-nice
...
...
```
**getval**:

```
/opt/collectd/bin/collectdctl getval boi.a1501/load/load
shortterm=6.000000e-02
midterm=6.000000e-02
longterm=6.000000e-02
```


Mcollective
-----------

The `collectdsocket` plugin allows you to query the collective to get values from all of these socket interfaces. There are a few modes to execute with:

**getall**:

Will get _all_ values from all metrics on the selected hosts. If you don't filter you will get the info from all hosts:

```
mco collectdsocket getall

 * [ ============================================================> ] 21 / 21

host.example.com                   status=OK
     host.example.com/cpu-0/cpu-idle=99.899960
     host.example.com/cpu-0/cpu-interrupt=0.000000
     host.example.com/cpu-0/cpu-nice=0.000000
     host.example.com/cpu-0/cpu-softirq=0.000000
     host.example.com/cpu-0/cpu-steal=0.000000
     host.example.com/cpu-0/cpu-system=0.033333
     host.example.com/cpu-0/cpu-user=0.050000
     host.example.com/cpu-0/cpu-wait=0.016667
     host.example.com/df-root/df_complex-free=12654930000.000000
     ...
     ...
     ...
```

**getthresh**:

Will gather all stats of a given filter type (can be regex filter) then based on the critical and warning thresholds set will display which servers fall out of those thresholds. In this example we search the count of logged in users and set a warn/crit thresholds:

```
mco collectdsocket getthresh --filter users --warn 1 --crit 2
CRITICAL  : host1.example.com          [host1/users/users=2.000000]
              OK: 26
         WARNING: 0
        CRITICAL: 1
         UNKNOWN: 0

Finished processing 27 / 27 hosts in 420.39 ms

```

This mode could then be used by Nagios to alert on certain statistics.

**getval**

**NOT IMPLEMENTED**: This would be similar to the collectd getval built in option.  Simply ask for the value of a specific metric across the collective.


Future
------
I use this module for some basic Nagios alerting currently.  It has **LOTS** of room for improvement and was my first mcollective plugin so it's very rough around the edges.  I wanted to get it out there in hopes that the idea would be useful for someone.  I'd be glad to take pull requests to fix some of the glaring issues it has.

It might even be cool in the future to allow the collectd socket data to be used for discovery by mcollective.

Threshold values are not sanitized properly and could stand to have some more flexibility than currently exists.

Also note, my mcollective system is an old 1.2.0 version so this plugin may not work properly in new collectives.  I wrote it over a year ago and my mcollective version was old then. I'm sure there are better ways to do things now in newer versions aside from the horrible coding I did on it.
