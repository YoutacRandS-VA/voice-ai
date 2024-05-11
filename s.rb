require 'json'

file_path = "/Users/qppn/Desktop/rails/voiceai/app/controllers/speakes.json"  # Update the path to where your JSON file is stored

# Read the file and parse it into a Ruby Hash
file_content = File.read(file_path)
data_hash = JSON.parse(file_content)

# Iterate through the data array and print the desired fields
data_hash["data"].each do |item|
  puts "ID: #{item['speaker_id']}, URL: #{item['thumbnail_large']}"
end
