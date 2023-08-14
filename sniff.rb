require 'nokogiri'
require 'set'
require 'awesome_print'

def extract_links(file_path)
  content = File.read(file_path)
  doc = Nokogiri::HTML(content)

  # Extract timestamp from file name
  timestamp = file_path.match(/(\d{14})\.html/).captures[0]

  links = doc.css('a').map { |link| [link['href'], timestamp] }
  links.reject { |(url, _)| url.nil? || url.empty? }
end

def scan_directory(directory)
  ap "Scanning directory: #{directory}"
  files = Dir.glob("#{directory}/**/*.html")
  ap "Found #{files.count} files"

  link_timestamps = files.flat_map do |file_path| 
    ap "Scanning file: #{file_path}"
    result = extract_links(file_path)
    ap "Found #{result.count} links"
    result
  end

  # Group by URLs and associate each URL with its earliest timestamp
  link_counts = link_timestamps.group_by { |(url, _)| url }
                               .transform_values do |timestamps|
                                 count = timestamps.size
                                 earliest_timestamp = timestamps.min_by { |(_, timestamp)| timestamp }[1]
                                 [count, earliest_timestamp]
                               end
  
  ap "Found #{link_counts.count} unique links"
  link_counts
end

Dir.mkdir('analysis') unless Dir.exist?('analysis')

def format_timestamp(timestamp_str)
  # Convert timestamp string "YYYYMMDDHHMMSS" to "YYYY-MM-DD HH:MM:SS"
  formatted = timestamp_str.gsub(
    /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/,
    '\1-\2-\3 \4:\5:\6'
  )
end

def save_to_file(url_counts, file_path = "analysis/#{Time.now.strftime('%Y%m%d%H%M%S')}_url_counts.html")
  ap "Saving to file: #{file_path}"

  # Sort by count (ascending) and then by reverse timestamp (descending)
  sorted_url_counts = url_counts.sort_by { |_url, (count, timestamp)| [count, -timestamp.to_i] }

  builder = Nokogiri::HTML::Builder.new do |doc|
    doc.html {
      doc.head {
        # Link to the local stylesheet here
        
        doc.link(:rel => "stylesheet", :href => "https://fonts.googleapis.com/css2?family=Megrim&display=swap", :type => "text/css")
        doc.link(:rel => "stylesheet", :href => "../styles.css", :type => "text/css")
      }
      doc.body {
        sorted_url_counts.each { |url, (count, timestamp)| 
          doc.p {
            doc.text " - Count: #{count} - First Appeared: #{format_timestamp(timestamp)}"
            doc.a(url, :href => url)
          }
        }
      }
    }
  end

  File.open(file_path, 'w') do |file|
    file.write(builder.to_html)
  end
end



to_sniff = ['./master_list/aliens', './master_list/strange_earth', './master_list/ufo', './master_list/ufob']
odors = to_sniff.map { |directory| scan_directory(directory) }.reduce({}) { |acc, hsh| acc.merge(hsh) { |_, (old_count, old_time), (new_count, new_time)| [old_count + new_count, [old_time, new_time].min] }}

save_to_file(odors)
