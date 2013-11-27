require 'socket'

module MCollective
    module Agent
        class Collectdsocket<RPC::Agent
            metadata :name        => "Collectd Socket Agent",
                     :description => "Interface to Collectd Unix Socket",
                     :author      => "Matt Pascoe",
                     :license     => "GPLv2",
                     :version     => "1.1",
                     :url         => "http://github.com/opennetadmin/collectdsocket",
                     :timeout     => 15

            # get plugin setting or use default
            def startup_hook
                @socketpath = @config.pluginconf["collectdsocket.socketpath"] || "/opt/collectd/var/run/collectd-unixsock"
            end

            # test that we even should run
# MDP: when we have newer mco we can use this to test if the module should even run or not
#            activate_when do
#                File.exists?(socketpath)
#            end

            # Get single metric value based on filter
            action "getval" do
                validate :filter, String

                filt = Regexp.new(request[:filter])
                out = call_sock("getval", filt)

                # error if we didnt find anything
                if out.empty? then
                   reply.fail "ERROR: Cant find metric"
                else
                    out.each do |fmetric, fvalue|
                        # send back our data
                        reply[:entry] = fmetric
                        reply[:value] = fvalue
                    end
                end
            end

            # Get single metric value based on filter
            action "getthresh" do
                validate :filter, String
                validate :warn, String
                validate :crit, String

                filt = Regexp.new(request[:filter])
                out = call_sock("getthresh",filt)

                # error if we didnt find anything
                if out.empty? then
                   reply.fail "ERROR: Cant find metric"
                   reply[:exitcode] = 3
                else
                    out.each do |fmetric, fvalue|
                        # send back our data
                        reply[:entry] = fmetric
                        reply[:value] = fvalue
                        if fvalue > request[:warn] then
                            reply[:exitcode] = 1
                            reply.fail "WARNING"
                        end
                        if fvalue > request[:crit] then
                            reply[:exitcode] = 2
                            reply.fail "CRITICAL"
                        end
                    end
                end
            end

            # Return all metrics and values 
            action "getall" do
                out = call_sock("getall",nil)
                reply[:output] = out.sort
            end


            # Function to gather the data and return it
            private
            def call_sock(mode,filt)

                output = Hash.new

                begin
                  # open our socket
                  # maybe someday make this an option
                  socket = UNIXSocket.new(@socketpath)
                
                  # get a list of all metrics on the system
                  socket.puts("LISTVAL")
            
                  # count how many metrics on the system
                  count = socket.gets.split[0]
            
                  list = []
                  #loop through each metric found
                  Integer(count).times do
                    # add the name of the metric to our list
                    list << socket.gets.split[-1]
                  end

                  # for each metric get its value
                  list.each do |entry|
                    # ask the socket for the value of this entry
                    socket.puts('GETVAL "'+entry+'"')
                    # skip the count
                    c = socket.gets.split[0]
                    Integer(c).times do
                      # display the name and value
                      result = socket.gets
                      varname = result.split("=")[0]
                      value = result.split("=")[-1].chomp
                      if varname == 'value' then
                        metric = entry
                      else
                        metric = entry+'/'+varname
                      end

                      if mode == 'getval' or mode == 'getthresh' then
                          # see if we match our filter
                          # If your filter matches more than one metric
                          # then you will just get the last one found
                          # i.e. it will always return ONE
                          if metric.match(filt) then
                              output[metric] = value
                          end
                      else 
                          output[metric] = value
                      end

                    end
                  end

                  # close the socket
                  socket.close

                  # return our data
                  output

                rescue
                  logger.warn("ERROR: Please check socket file: "+ @socketpath)
                  reply.fail! "ERROR: Please check socket file: "+ @socketpath
                end

             end


        end
    end
end
