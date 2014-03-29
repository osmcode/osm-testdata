#!/usr/bin/ruby
#
#  create-sql-for-multipolygons.rb REFERENCE-JSON-FILE
#
#  Reads the given reference JSON file and creates the
#  SQL commands to create all multipolygons contained
#  in the file. The SQL commands are written to stdout.
#

require 'json'

open(ARGV[0]) do |file|
    reference_data = JSON.load(file, nil, {:symbolize_names => true})
    reference_data.each do |test|
        if test[:areas]
            test[:areas].each do |area|
                if area[:wkt] != 'INVALID'
                    puts "INSERT INTO multipolygons (test_id, id, from_type, variant, geom) VALUES (#{test[:test_id]}, #{area[:from_id]}, '#{area[:from_type][0]}', '#{area[:variant]}', MultiPolygonFromText('#{area[:wkt]}', 4326));"
                end
            end
        end
    end
end

