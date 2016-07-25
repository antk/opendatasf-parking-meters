require 'csv'

parking_meters_csv = 'Parking_meters.csv'
meter_operating_schedules = 'Meter_Operating_Schedules.csv'

log_file = File.open('debug.log', 'w')

# for progress indication
line_count = File.foreach(parking_meters_csv).inject(0) { |c, line| c+1 }
line_count = line_count - 1
read_count = 0

# create a hash with post_id as the key
puts "Reading csv file: " + parking_meters_csv
meter_hash = Hash.new

CSV.foreach(parking_meters_csv, :headers => true) do |csv_obj|
  # log_file.puts(csv_obj['STREETNAME'])
  meter_info = Hash.new # create a new hash for each row using header
  csv_obj.headers.each do |header|
    meter_info[header] = csv_obj[header]
  end
  # add that row hash to each post_id
  meter_hash[csv_obj['POST_ID']] = meter_info
  # log_file.puts(meter_hash[csv_obj['POST_ID']])
  read_count += 1
  STDOUT.write "\rProcessed #{read_count}/#{line_count} records"
end

# puts meter_hash['202-00010']

# output of meter_hash['354-20160']:
# {
#   "POST_ID"=>"354-20160", 
#   "MS_ID"=>"-", 
#   "MS_SPACEID"=>"0",
#   "CAP_COLOR"=>"Grey",
#   "METER_TYPE"=>"SS",
#   "SMART_METE"=>"Y",
#   "ACTIVESENS"=>"N",
#   "JURISDICTI"=>"SFMTA",
#   "ON_OFF_STR"=>"ON",
#   "OSP_ID"=>"0",
#   "STREET_NUM"=>"2016",
#   "STREETNAME"=>"CHESTNUT ST",
#   "STREET_SEG"=>"3977000",
#   "RATEAREA"=>"Area 5",
#   "SFPARKAREA"=>"Marina",
#   "LOCATION"=>"(37.8007983983, -122.4368696024)"
# }

# now go through meter_operating_schedules and add desired columns

# create new file
out_file = File.open('merged-tmp.csv', 'w')
a_row = nil

# for progress
meter_op_line_count = File.foreach(meter_operating_schedules).inject(0) { |c, line| c+1 }
meter_op_line_count = meter_op_line_count - 1
merged_count = 0

puts "\nMerging " + parking_meters_csv + " and " + meter_operating_schedules + "\n"
CSV.foreach(meter_operating_schedules, :headers => true) do |row|
  post_id = row['Post ID']
  if(!meter_hash[post_id].nil?)
    # puts post_id + ' is nil'
    meter_rec = meter_hash[post_id]
    new_row = row

    street_num = meter_rec['STREET_NUM']
    street_name = meter_rec['STREETNAME']
    ms_id = meter_rec['MS_ID']
    ms_spaceid = meter_rec['MS_SPACEID']
    location = meter_rec['LOCATION']
    latlng_captures = location.scan(/(-?\d+\.?\d+)/).flatten
    lat = latlng_captures[0]
    lng = latlng_captures[1]
    
    new_row['STREET_NUM'] = meter_rec['STREET_NUM']
    new_row['STREETNAME'] = street_name
    new_row['MS_ID'] = ms_id
    new_row['MS_SPACEID'] = ms_spaceid
    new_row['LAT'] = lat
    new_row['LNG'] = lng
    a_row = row
    out_file.write(new_row)
  else
    # record in meter hash not found, add as is
    out_file.write(row)
    log_file.puts(post_id + ' is nil, add as is')
  end
  merged_count += 1
  STDOUT.write "\rMerged #{merged_count}/#{meter_op_line_count} records"
end
out_file.close

# now have to add header row to csv file
# requires creating new file, write header row, go through out_file, write every line to new file - seems kind of lame just to put in the header row
final_file_name = 'merged-final.csv'
merged_file = File.open(final_file_name, 'w')
merged_file.puts(a_row.headers.join(','))

puts "\nWriting new csv file: " + final_file_name
count = 0;
File.open('merged-tmp.csv').each do |line|
  merged_file.puts(line)
  count += 1
end
puts "New csv file created.  Use " + final_file_name
merged_file.close
log_file.close
