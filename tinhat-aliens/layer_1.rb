require 'httparty'
require 'json'
require 'fileutils'
require 'awesome_print'
require 'nokogiri'

# Define the Reddit API endpoint for the r/ufos subreddit
target = 'https://www.reddit.com/r/aliens/new/.json'
tag = 'L1::ALINES::'

# Number of desired results
desired_results = 500
ap '👽 SCAN ACTIVE 👽'

# Create folders to store the generated files
FileUtils.mkdir_p('json_data/aliens')
FileUtils.mkdir_p('master_list/aliens')
FileUtils.mkdir_p('detected_changes/aliens')

# Helper method to extract most common words from titles as keywords
def extract_keywords(posts)
  all_titles = posts.map { |post| post['data']['title'] }
  all_words = all_titles.flat_map { |title| title.downcase.split(/\W+/) }
  word_count = all_words.each_with_object(Hash.new(0)) { |word, count| count[word] += 1 }
  word_count.sort_by { |_word, count| -count }.map(&:first).take(33)
end

# Helper method to process posts and extract the desired number of results
def process_posts(posts, keywords_to_spot, desired_results)
  # Create an array to store the results along with their relevance scores
  results = []

  posts.each do |post|
    title = post['data']['title']
    url = "https://www.reddit.com#{post['data']['permalink']}"

    # Calculate the relevance score of the title based on keyword matches
    relevance = keywords_to_spot.sum { |keyword| title.scan(/#{keyword}/i).size }

    # Add the title and URL to the results array along with the relevance score
    results << { title: title, url: url, relevance: relevance }
  end

  # Sort the results in descending order of relevance
  results.sort_by! { |result| -result[:relevance] }

  # Return the top desired_results number of results
  results.first(desired_results)
end

# Send requests to the Reddit API with pagination to fetch the desired number of results
response = HTTParty.get(target, query: { limit: 100 }, headers: { 'User-Agent' => 'MyApp/1.0' })

# Check if the request was successful
if response.success?
  # Parse the JSON response
  data = JSON.parse(response.body)

  # Generate the unique filename with timestamp
  timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  json_filename = "json_data/aliens/#{tag}#{timestamp}.json"
  html_filename = "master_list/aliens/#{tag}#{timestamp}.html"

  # Initialize the counter and process the initial posts
  counter = 1
  keywords_to_spot = extract_keywords(data['data']['children'])
  results = process_posts(data['data']['children'], keywords_to_spot, desired_results)

  # Fetch remaining posts until the desired number is reached
  while counter <= desired_results && data['data']['after']
    after_param = data['data']['after']
    response = HTTParty.get(target, query: { limit: 100, after: after_param }, headers: { 'User-Agent' => 'MyApp/1.0' })

    if response.success?
      data = JSON.parse(response.body)
      keywords_to_spot = extract_keywords(data['data']['children'])
      results += process_posts(data['data']['children'], keywords_to_spot, desired_results)
      results = results.first(desired_results) # Trim the results to desired_results
    else
      puts "Failed to retrieve data from Reddit. Error code: #{response.code}".colorize(:light_red)
      break
    end
  end

  File.open(json_filename, 'w') do |log_file|
    log_file.write(JSON.pretty_generate(data))
  end

  # Write the results to the unique HTML file with timestamp
  File.open(html_filename, 'w') do |result_file|
    result_file.puts <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>"Data Collected from r/ALIENS @ #{timestamp}"</title>
        <link rel="stylesheet" type="text/css" href="style.css">
      </head>
      <body>
        <h1>Data Scraped from r/aliens</h1>
        <h2>Top 20 Results:</h2>
        <ol>
    HTML

    # Display the top 20 results based on relevance
    results.first(20).each do |result|
      result_file.puts "        <li><a href=\"#{result[:url]}\">#{result[:title]}</a></li>"
    end

    result_file.puts <<~HTML
      </ol>
      <h2>All Results (Without Relevance Scores):</h2>
      <ol>
    HTML

    results.each do |result|
      result_file.puts "        <li><a href=\"#{result[:url]}\">#{result[:title]}</a></li>"
    end

    result_file.puts <<~HTML
        </ol>
        <p>Successfully fetched a total of #{results.size} results.</p>
      </body>
      </html>
    HTML
  end

  puts "👽 Results saved to '#{html_filename}'."
else
  puts "DATA: COLLECTION ERROR: Error code: #{response.code}".colorize(:light_red)
end
