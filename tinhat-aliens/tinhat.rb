require 'awesome_print'

# Script Location
layer_1 = './tinhat-aliens/layer_1.rb'
layer_2 = './tinhat-aliens/layer_2.py'
layer_3 = './tinhat-aliens/judge.py'

# Run the script every x min
system('ruby', layer_1)
puts "Script executed at: #{Time.now}"
system('python3', layer_2)
ap "ARCHIVED @ #{Time.now}"
system('python3', layer_3)
ap "ANALYZED @ #{Time.now}"
