import os
import requests
from bs4 import BeautifulSoup
import glob
import time
from termcolor import colored

def get_most_recent_file(directory):
    """
    Returns the path of the most recent file in the given directory.
    """
    files = glob.glob(f"{directory}/*")
    return max(files, key=os.path.getmtime)

def get_all_links_from_file(filename):
    """
    Returns all the links from the given HTML file.
    """
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            content = file.read()

        soup = BeautifulSoup(content, 'html.parser')
        return [a['href'] for a in soup.find_all('a', href=True)]

    except Exception as e:
        print(colored(f"Error reading file {filename}: {e}", 'red'))
        return []

def is_link_valid(url):
    """
    Checks if a link is valid by trying to request it.
    """
    try:
        response = requests.head(url, allow_redirects=True, timeout=5)
        return response.status_code < 400
    except requests.RequestException:
        return False

def main():
    # Automatically select the most recent file from the analysis directory
    html_file = get_most_recent_file('analysis')
    
    print(colored(f"Checking links in the file: {html_file}", 'cyan'))
    
    links = get_all_links_from_file(html_file)

    if not links:
        print(colored("No links found or there was an error reading the file.", 'red'))
        return

    print(colored(f"Found {len(links)} links. Checking...", 'cyan'))

    for link in links:
        print(colored(f"Checking: {link}", 'yellow'))
        if not is_link_valid(link):
            print(colored(f"Invalid link: {link}", 'red'))
        else:
            print(colored("Valid link", 'green'))
        time.sleep(1)  # Wait for 1 second

    print(colored("Done checking links.", 'cyan'))

if __name__ == '__main__':
    main()
