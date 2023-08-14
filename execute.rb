require 'awesome_print'

# Script Location
scripts = [
  './tinhat-aliens/tinhat.rb',
  './tinhat-strangeEarth/tinhat.rb',
  './tinhat-ufo/tinhat.rb',
  './tinhat-ufob/tinhat.rb'
]

loop do
  ap 'r/aliens'
  system('ruby', scripts[0])
  sleep(3)
  ap 'r/ufos'
  system('ruby', scripts[2])
  sleep(3)
  ap 'r/strangeEarth'
  system('ruby', scripts[1])
  sleep(3)
  ap 'r/ufob'
  system('ruby', scripts[3])
  sleep(90)
end