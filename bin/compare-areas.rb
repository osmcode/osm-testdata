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

open('compare-areas.out', 'w') do |file|
    file.puts "Running at #{Time.now}"
end

file = open('compare-areas.out', 'a')
file.sync = true

def print_tags(tags)
    tags.map{ |k,v|
        "#{k}=#{v}"
    }.join(', ')
end

def compare_tags(ref, tst)
    if ref.nil?
        if tst.nil?
            return [true, "no tags => OK"]
        else
            return [false, "has tags but ref does not => ERR"]
        end
    end

    if tst.nil?
        return [false, "missing tags (#{ print_tags(ref) }) => ERR"]
    end

    refcpy = ref
    ref.each do |k,v|
        if tst[k] != v
            return [false, "tag key '#{k}' should be '#{v}' but is '#{tst[k]}' => ERR"]
        end
        tst.delete k
        refcpy.delete k
    end

    if refcpy.size != 0
        return [false, "missing tags (#{ print_tags(refcpy) }) => ERR"]
    end

    if tst.size != 0
        return [false, "additional tags (#{ print_tags(tst) }) => ERR"]
    end

    return [true, 'tags match => OK']
end

def compare_area(ref, t)
    okay = false
    details = ''

    ref[:areas].each do |area|
        command = %Q{#{COMPARE_WKT} "#{area[:wkt]}" "#{t[:wkt]}" 2>>compare-areas.out}
        result = `#{command}`
        result.chomp!
        (tags_okay, tags_detail) = compare_tags(area[:tags], t[:tags])

        if result =~ / OK$/ and tags_okay and !area[:used]
            area[:used] = true
            okay = true
        end

        details += " [#{area[:variant]}: #{result}, #{tags_detail}]"
    end

    return [okay, details]
end

reference_data.each do |ref|
    print "#{ref[:test_id]}..."
    file.puts "============================\n#{ref[:test_id]}:"

    td = test_data.select do |td|
        td[:test_id] == ref[:test_id]
    end

    if !td
        STDERR.puts "Missing test data for test id #{ref[:id]}\n"
        exit 1
    end

    okay = true
    details = ''
    td.each do |t|
        (o, d) = compare_area(ref, t)
        if ! o
            okay = false
        end
        details += d
    end

    puts " \033[1;#{ okay ? '32mOK ' : '31mERR' }\033[0m #{details}"
end

file.close

