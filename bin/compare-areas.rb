#!/usr/bin/ruby
#
#  compare-areas.rb REFERENCE-JSON-FILE TEST-JSON-FILE
#
#  Compare the areas created by running the test program in the TEST-JSON-FILE
#  to the areas described in the REFERENCE-JSON-FILE.
#
#  All geometries and tags from the reference data file are checked against
#  geometries in the test data file. One line per reference geometry is output
#  containing the test id, the word "OK" or "ERR" in green or red,
#  respectively, and in square brackets the results for each of the variants in
#  the reference data file.
#
#  More detailed (debug) output can be found in the file
#  compare-areas.out.
#

require 'json'

COMPARE_WKT="#{File.dirname($0)}/compare-wkt.sh"

file = open(ARGV[0])
reference_data = JSON.load(file, nil, {:symbolize_names => true})
file.close

file = open(ARGV[1])
test_data = JSON.load(file, nil, {:symbolize_names => true})
file.close

open('compare-areas.log', 'w') do |file|
    file.puts "Running at #{Time.now}"
end

LOG = open('compare-areas.log', 'a')
LOG.sync = true

def print_tags(tags)
    tags.map{ |k,v|
        "#{k}=#{v}"
    }.join(', ')
end

# Compare set of reference and test tags given as hashes
def compare_tags(ref, tst)
    LOG.puts "    Comparing tags..."
    if ref.nil?
        if tst.nil?
            LOG.puts "      No tags => OK"
            return true
        else
            LOG.puts "      Has tags but ref does not => ERR"
            return false
        end
    end

    if tst.nil?
        LOG.puts "      Missing tags (#{ print_tags(ref) }) => ERR"
        return false
    end

    refcpy = ref
    ref.each do |k,v|
        if tst[k] != v
            LOG.puts "      Tag key '#{k}' should be '#{v}' but is '#{tst[k]}' => ERR"
            return false
        end
        tst.delete k
        refcpy.delete k
    end

    if refcpy.size != 0
        LOG.puts "      Missing tags (#{ print_tags(refcpy) }) => ERR"
        return false
    end

    if tst.size != 0
        LOG.puts "      Additional tags (#{ print_tags(tst) }) => ERR"
        return false
    end

    LOG.puts '      Tags match => OK'
    return true
end

# Compare reference and test geometries given as WKT
def compare_geom(ref, tst)
    LOG.puts "    Comparing geometries..."
    command = %Q{#{COMPARE_WKT} "#{ref}" "#{tst}" 2>>compare-areas.log}
    result = `#{command}`
    result.chomp!
    LOG.puts "      #{result}"
    return result =~ / OK$/
end

# Compare all aspects of reference to test area
def compare_area(area, t)
    geom_okay = compare_geom(area[:wkt], t[:wkt])
    tags_okay = compare_tags(area[:tags], t[:tags])
    from_okay = (area[:from_id] == t[:from_id] && area[:from_type] == t[:from_type])

    return geom_okay && tags_okay && from_okay
end


def check_variant(variant, areas, td)
    LOG.puts "  Checking variant #{variant}:"

    used_areas = {}

    td.each_with_index do |t, tindex|
        areas.select{ |area| !used_areas[area] }.each do |area|
            LOG.puts "    Checking test area ##{tindex} against reference area ##{area[:index]}..."
            result = compare_area(area, t)
            if result
                used_areas[area] = true
                break
            end
        end
    end

    if used_areas.size != areas.size
        LOG.puts "    Not all areas created => ERR"
        return false
    end

    true
end

# Get all the test cases from the reference data and check all that
# have area information in turn
reference_data.select{ |ref| ref[:areas] }.each do |ref|

    # Number each area in each variant (for debugging output)
    ref[:areas].each do |variant, areas|
        areas.each_with_index do |area, index|
            area[:index] = index
        end
    end

    LOG.puts "\n============================\nTesting id #{ref[:test_id]}:"
    print "#{ref[:test_id]}..."

    # find all test data for this test id
    td = test_data.select do |td|
        td[:test_id] == ref[:test_id]
    end

    if !td
        STDERR.puts "Missing test data for test id #{ref[:id]}\n"
        exit 1
    end

    # check each variant
    result = ref[:areas].map{ |variant, areas|
        variant_result = check_variant(variant, areas, td)
        LOG.puts "  Variant result: #{ variant_result ? 'OK' : 'ERR' }"
        variant_result
    }.include?(true)

    LOG.puts "Final result: #{ result ? 'OK' : 'ERR' }"
    puts " \033[1;#{ result ? '32mOK ' : '31mERR' }\033[0m"
end

LOG.close

