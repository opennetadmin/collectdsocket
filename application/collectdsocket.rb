#require 'mcollective'
class MCollective::Application::Collectdsocket<MCollective::Application
   description "Client to the Collectd socket system"
   usage "Usage: collectdsocket <getall|getthresh>"

   option :filter,
    :description    => "Define a filter",
    :arguments      => ["--filter REGEX", "-f REGEX"]
#    :required       => true

   option :warn,
    :description    => "Warning Threshold",
    :arguments      => ["--warn NUM", "-w NUM"]
#    :required       => true

   option :crit,
    :description    => "Critical Threshold",
    :arguments      => ["--crit NUM", "-c NUM"]
#    :required       => true


   def main
      command = ARGV.shift

      mc = rpcclient("collectdsocket")

      case command
      when "getthresh"
          mc.progress = false

          stats = [0, 0, 0, 0]
          statuscodes = [0]

          mc_results = mc.getthresh(:filter => configuration[:filter], :warn => configuration[:warn], :crit => configuration[:crit])
            mc_results.each do |result|
              exitcode = result[:data][:exitcode].to_i
              statuscodes << exitcode
              if exitcode >=0 and exitcode < 4
                stats[exitcode] += 1
              end
              if mc.verbose
                printf("%-40s status=%s\n", result[:sender], result[:statusmsg])
                printf("    %-40s: %f\n\n", result[:data][:entry], result[:data][:value]) if result[:data][:entry]
              else
                if [1,2,3].include?(exitcode)
                  printf("%-10s: %-30s [%s=%f]\n", result[:statusmsg], result[:sender], result[:data][:entry], result[:data][:value])
                end
              end
          end


              printf("\nStatusses:\n") if mc.verbose
              printf("              OK: %d\n", stats[0])
              printf("         WARNING: %d\n", stats[1])
              printf("        CRITICAL: %d\n", stats[2])
              printf("         UNKNOWN: %d\n", stats[3])

              printrpcstats :caption => "#{configuration[:command]} Collectd results"

      # Display all the socket entries
      when "getall"
          mc_results = mc.getall()
            mc_results.each do |result|
                printf("%-40s status=%s\n", result[:sender], result[:statusmsg])
                if !result[:data].empty? then
                  result[:data][:output].each do |key,line|
                    if line == "NaN"
                      printf("     %s=%s\n", key,line)
                    else
                      printf("     %s=%f\n", key,line)
                    end
                  end
                else
                  puts("Collectdsocket: #{command} returned no data")
                end
            end
      else
         puts("Collectdsocket; Invalid command: #{command}")
         exit! 1
      end
   end
end
