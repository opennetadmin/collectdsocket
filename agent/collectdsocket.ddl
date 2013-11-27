metadata :name        => "Collectd Socket Agent",
         :description => "Interface to Collectd Unix Socket",
         :author      => "Matt Pascoe",
         :license     => "GPLv2",
         :version     => "1.0",
         :url         => "http://github.com/opennetadmin/collectdsocket",
         :timeout     => 15

action "getval", :description => "Get collectd values" do
    display :always

    input :filter,
          :prompt      => "Metric Filter Regex",
          :description => "The regex used to select a specific metric",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 150

    output :entry,
          :description => "Name of specific metric",
          :display_as  => "Metric Name"

    output :value,
          :description => "Value of specific metric",
          :display_as  => "Metric Value"
end

action "getthresh", :description => "Get collectd values relative to a threshold" do
    display :always

    input :filter,
          :prompt      => "Metric Filter Regex",
          :description => "The regex used to select a specific metric",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 150

    output :entry,
          :description => "Name of specific metric",
          :display_as  => "Metric Name"

    output :value,
          :description => "Value of specific metric",
          :display_as  => "Metric Value"
end

action "getall", :description => "Get all collectd key values" do
    display :always

    output :entry,
          :description => "Name of specific metric",
          :display_as  => "Metric Name"

    output :value,
          :description => "Value of specific metric",
          :display_as  => "Metric Value"
end
