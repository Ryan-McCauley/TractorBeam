# Choose a base image that includes Ruby. 
# This example uses the official Ruby image from Docker Hub.
FROM ruby:3.2.2

# Install Python and pip
RUN apt-get update -y && apt-get install -y python3 python3-pip

# Create a directory in the Docker image to store your app, and make it the working directory
WORKDIR /data/aliens

# Copy the Gemfile and Gemfile.lock from your app directory into the Docker image
COPY Gemfile Gemfile.lock ./

# Install any gems your app needs
RUN bundle install

# Install Python libraries your app needs
RUN apt install python3-requests -y
RUN apt install python3-bs4 -y

# Copy the rest of your app into the Docker image
COPY . .

# The command that starts your app
CMD ["ruby", "./tinhat.rb"]
