require 'nokogiri'
require 'set'
require 'awesome_print'
require 'json'


# Creates directory for output page.
Dir.mkdir('analysis') unless Dir.exist?('analysis')

SUBREDDIT_COLORS = {
  'Aliens' => 'limegreen',     # An alien-like green color.
  'Ufo' => 'skyblue',         # UFOs in the sky.
  'Strange_earth' => 'purple',  # The mysteries of the Earth.
  'Ufob' => 'goldenrod'    # Another UFO related color.
}


def extract_subreddit_and_title(url)
  match = url.match(/https:\/\/www\.reddit\.com\/r\/(\w+)\/comments\/\w+\/([^\/]+)\/?$/)
  if match
    subreddit, title = match.captures
    [subreddit.capitalize, title.tr('_', ' ')]
  else
    [nil, url]  # Return the original URL if parsing fails.
  end
end

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

  link_counts = link_timestamps.group_by { |(url, _)| url }
                               .transform_values do |timestamps|
                                 count = timestamps.size
                                 earliest_timestamp = timestamps.min_by { |(_, timestamp)| timestamp }[1]
                                 [count, earliest_timestamp]
                               end
  
  ap "Found #{link_counts.count} unique links"
  link_counts
end

def format_timestamp(timestamp_str)
  # Convert timestamp string "YYYYMMDDHHMMSS" to "YYYY-MM-DD HH:MM:SS"
  formatted = timestamp_str.gsub(
    /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/,
    '\1-\2-\3 \4:\5:\6'
  )
end

def save_to_file(url_counts, file_path = "analysis/#{Time.now.strftime('%Y%m%d%H%M%S')}_url_counts.html")
  ap "Saving to file: #{file_path}"

  # Group by days
  grouped_by_day = url_counts.group_by { |_, (_, timestamp)| timestamp[0..7] }

  builder = Nokogiri::HTML::Builder.new do |doc|
    doc.html {
      doc.head {
        doc.link(:rel => "stylesheet", :href => "https://fonts.googleapis.com/css2?family=Megrim&display=swap", :type => "text/css")
        doc.link(:rel => "stylesheet", :href => "../styles.css", :type => "text/css")
        doc.style {
          <<-CSS
            body, select {
              font-family: 'Megrim', sans-serif;
            }
          CSS
        }
        
        serialized_colors = SUBREDDIT_COLORS.to_json

        doc.script {
          <<-JS
            document.addEventListener("DOMContentLoaded", function() {
              var dropdowns = document.querySelectorAll("select");
              var subredditColors = #{serialized_colors};
        
              dropdowns.forEach(function(dropdown) {
                dropdown.addEventListener("change", function(e) {
                  var selectedOption = e.target.options[e.target.selectedIndex];
                  var subreddit = selectedOption.getAttribute('data-subreddit');
                  var color = subredditColors[subreddit] || 'gray'; // default color
        
                  e.target.style.backgroundColor = color;
                });
              });
            });
          JS
        }
        
        
      }
      doc.body {
        grouped_by_day.sort_by { |day, _| -day.to_i }.each do |day, day_url_counts|
          doc.label("Links from #{day}")
          doc.select(:onchange => "window.open(this.value,'_blank')") {  
            day_url_counts.sort_by { |_url, (count, timestamp)| [count, -timestamp.to_i] }.each do |url, (count, timestamp)|
              subreddit, title = extract_subreddit_and_title(url)
              display_text = if subreddit
                "Count: #{count} #{subreddit}:: #{title}"
              else
                "Count: #{count} - #{url}"  # Fallback to URL if parsing fails
              end
              
              option_color = SUBREDDIT_COLORS[subreddit] || 'gray'  # Default to gray if the subreddit isn't in our mapping
              doc.option(display_text, :value => url, :data => {:subreddit => subreddit})
            end
          }
        end
      }
    }
  end

  File.open(file_path, 'w') do |file|
    file.write(builder.to_html)
  end

  # Open the saved file in the default browser
  # system("open '#{file_path}'") if RUBY_PLATFORM =~ /darwin/   # For macOS
  system("xdg-open '#{file_path}'") if RUBY_PLATFORM =~ /linux/  # For Linux
  # system("start '#{file_path}'") if RUBY_PLATFORM =~ /mswin|mingw|cygwin/  # For Windows
end

to_sniff = ['./master_list/aliens', './master_list/strange_earth', './master_list/ufo', './master_list/ufob']
odors = to_sniff.map { |directory| scan_directory(directory) }.reduce({}) { |acc, hsh| acc.merge(hsh) { |_, (old_count, old_time), (new_count, new_time)| [old_count + new_count, [old_time, new_time].min] }}

save_to_file(odors)
