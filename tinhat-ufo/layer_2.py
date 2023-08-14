import os
import requests
from bs4 import BeautifulSoup

def save_site_data(url, output_folder):
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')
        title = soup.title.string.strip()

        # Create a filename based on the URL and title
        filename = f"{url.split('://')[1].replace('/', '_')}_{title}.html"
        filepath = os.path.join(output_folder, filename)

        # Check if the file already exists in the output folder
        if not os.path.exists(filepath):
            # Save the site data to a file
            with open(filepath, 'wb') as f:
                f.write(response.content)

            print(f"NEW DATA:: Saved to {filepath}")
        else:
            print(f"Sniffing...")
    except requests.exceptions.RequestException as e:
        print(f"Error while fetching data from {url}: {e}")

def get_most_recent_file(folder_path):
    files = os.listdir(folder_path)
    if not files:
        raise ValueError("No files found in the input folder.")

    most_recent_file = max(files, key=lambda f: os.path.getmtime(os.path.join(folder_path, f)))
    return os.path.join(folder_path, most_recent_file)

def main():
    # Replace 'input_folder' with the path to the folder containing HTML files with URLs
    input_folder = 'master_list/ufo'
    # Replace 'output_folder' with the path to the folder where you want to save the site data
    output_folder = 'page_source/ufo'

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    input_file = get_most_recent_file(input_folder)

    with open(input_file, 'r') as f:
        lines = f.readlines()

    for line in lines:
        soup = BeautifulSoup(line, 'html.parser')  # Parse the HTML content
        links = soup.find_all('a', href=True)  # Find all <a> elements with href attributes
        for link in links:
            url = link['href']  # Extract the URL from the href attribute
            save_site_data(url, output_folder)

if __name__ == "__main__":
    main()
