Abstract:

This collection of scripts was inspired after seeing several comments on social media regarding secrecy and efforts to scrub certain posts related to UFO/UAPs and aliens.  
As a hard skeptic of claims made on the internet, I set about to capture and log all the source file of each page across several pages that I would suspect would have deleted posts.
All data is timestamped in the file names as they are created.



High level explaination of the file structure.

-`/tinhat-dirs`
  Each of these folders contains its own stand alone script for a particular subreddit that can be seen in the `layer_1.rb` file as the target.
  A particular script cycle can be executed in its entirety once by running `ruby tinhat.rb` within the related directory.
    
 - `layer_1.rb`
      This scraper goes to the target url and requests the first 500 objects, 100 at a time and compiles a list of the newest posts.  The output of this file will
      appear in a newly created folder labeled `master_list/your_target_dir`.  The raw json will also be saved to a created directory labeled `json_data/your_target_dir`. 
      Duplicate data will not be saved. 
			
 - `layer_2.py`
      This python script utilizes beautiful soup to scrape the file created by ruby under the `master_list` directory.  It will go and fetch the source html of the files in the master 
      list if they are unique and not already contained in the `page_source` directory and save them to that folder under the respective `page_source/your_target_dir` .  
			
 - `judge.py`
      The final auto script of this loop compares the two most recent files created in the `master_list/your_target_dir` and compares the lists of urls.  The script will generate a html file
      that is color coded in the git difference style(e.g. removed lines in red) and save that file to the `detected_changes/your_target` folder



`execute.rb`
  The main script for this app.  Running this script will run all included tinhat branches sequentially in an infinite loop, scraping data into the host folders.

`sniff.rb`
  This file will run a script that goes through all files in the `master_list` directory and outputs a new html page for operator analysis.  I've included a sci-fi themed `styles.css`
  to add just a little flair for the end effect.  The output file will show the links sorted by the number of times they appear across each unique sweep.  Clicking on the top links
  which have the lowest count will show the links most likely to have been removed as they will not show up in later scans.

`ping.py`
  This script will go through a list of all collected urls and see if they return a 200 status.  This tool runs in the console and does not generate an output file.



======================================

Required libraries and config

Python Req. (pip install)

    difflib
		
    requests
		
    bs4


Ruby Gems (gem install)

    httparty
		
    json
		
    fileutils
		
    awesome_print
		
    nokogiri
