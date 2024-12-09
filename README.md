# Rhinovirus Viewer

Rhinovirus Viewer is a web-based tool for visualizing rhinovirus genomic data using JBrowse2. This tool allows users to explore and analyze rhinovirus genomes and related data.

## Features

- Visualize rhinovirus genomic data
- Explore rhinovirus A, B, and C strains
- Integrated with JBrowse2 for advanced genomic visualization

## Usage Options

### Option 1: Use the GitHub Pages Website

You can simply use the Rhinovirus Viewer hosted on GitHub Pages:

- **Rhinovirus Viewer**: <a href="https://atamadon.github.io" target="_blank">atamadon.github.io</a>
- **JBrowse2 Instance**: <a href="https://atamadon.github.io/jbrowse2" target="_blank">atamadon.github.io/jbrowse2</a>

### Option 2: Install on Debian/Ubuntu Based Linux Distribution

Follow these steps to install and set up Rhinovirus Viewer on a Debian/Ubuntu based Linux distribution using the `install_linux.sh` script located in the `installation/` directory:

1. **Clone the Repository**

    ```sh
    git clone https://github.com/atamadon/atamadon.github.io.git
    cd atamadon.github.io
    ```

2. **Run the Installation Script**
    ```sh
    chmod +x installation/install_linux.sh
    ```

    ```sh
    ./installation/install_linux.sh
    ```

3. **Access the Viewer**

    Navigate to `http://your-server-ip/jbrowse2` in your web browser. Apache will output the IP address to the shell. Otherwise, run:
    ```sh
    ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
    ```
    To locate the server's IP address. 

4. **NOTE: Your milage may vary**

    Please be mindful of your system's installation environment. This method is prone to dependency errors, issues with networking, and general linux file permission headaches. Use the devcontainer option for a streamlined experience. 

### Option 3: Use a DevContainer in Visual Studio Code (Preferred)

The preferred option is to use a DevContainer in Visual Studio Code, which automatically installs all dependencies and launches an instance of the JBrowse viewer at `localhost/jbrowse2`. This option only requires Docker Engine to be installed locally.

1. **Install Docker Engine**

    Follow the instructions to install Docker Engine on your system: [Docker Installation Guide](https://docs.docker.com/get-docker/)

2. **Clone the Repository**

    ```sh
    git clone https://github.com/atamadon/atamadon.github.io.git
    cd atamadon.github.io
    ```

3. **Open in Visual Studio Code**

    Open the project in Visual Studio Code. You should see a prompt to reopen the project in a DevContainer. If not, open the `Command Palatte` and select `Remote-Containers: Reopen in Container`.

4. **Run the DevContainer Setup Script**

    The `install_devcontainer.sh` script will automatically run inside the DevContainer to install all dependencies and set up the JBrowse viewer.

5. **Access the Viewer**

    Navigate to `http://localhost/jbrowse2` in your web browser.