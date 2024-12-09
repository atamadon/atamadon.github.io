# Rhinovirus Viewer 🦏🦠

Rhinovirus Viewer is a web-based tool for visualizing rhinovirus genomic data using JBrowse2. After installation, this tool allows users to explore and analyze rhinovirus genomes and related data.

## Features

- Visualize rhinovirus genomic data
- Explore rhinovirus A, B, and C strains
- Integrated with JBrowse2 for advanced genomic visualization
- Expandable installation script to allow for addition of genome assemblies. Modify scripts in `installation/` to do so

## Installation Options

### Option 1: Use the GitHub Pages Website

You can simply use the Rhinovirus Viewer hosted on GitHub Pages:

- **Rhinovirus Viewer**: [atamadon.github.io](https://atamadon.github.io)
- **JBrowse2 Instance**: [atamadon.github.io/jbrowse2](https://atamadon.github.io/jbrowse2)

### Option 2: Install on Debian/Ubuntu Based Linux Distribution

Follow these steps to install and set up Rhinovirus Viewer on a Debian/Ubuntu based Linux distribution using the `install_linux.sh` script located in the `installation/` directory:

1. **Clone the Repository**

    ```sh
    git clone https://github.com/atamadon/atamadon.github.io.git
    cd atamadon.github.io
    ```

2. **OPTIONAL: Adding Additional Genome Assemblies**

    The installation script uses a bash arrays to store FTP links to the genome `FASTA` files and `GFF` track annotations. If you wish to add additional assemblies, simply aquire the FTP links to the corresponding `.fasta` and `.gff` files and add them to the `strains` and `tracks` bash arrays respectively in `installation/install_linux.sh`.

3. **Run the Installation Script**
    ```sh
    chmod +x installation/install_linux.sh
    ```

    ```sh
    ./installation/install_linux.sh
    ```

4. **Access the Viewer**

    Navigate to `http://your-server-ip/jbrowse2` in your web browser. Apache will output the IP address to the shell. Otherwise, run:
    ```sh
    ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
    ```
    To locate the server's IP address. 

5. **NOTE: Your milage may vary**

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

    Open the project in Visual Studio Code. You should see a VSCode prompt in the bottom right to reopen the project in a DevContainer. If not, open the `Command Palatte` and select `>Remote-Containers: Reopen in Container`.

4. **Run the DevContainer Setup Script**

    The `install_devcontainer.sh` script will automatically run inside the DevContainer to install all dependencies and set up the JBrowse viewer.

5. **OPTIONAL: Adding Additional Genome Assemblies**

    The installation script uses a bash arrays to store FTP links to the genome `FASTA` files and `GFF` track annotations. If you wish to add additional assemblies, simply aquire the FTP links to the corresponding `.fasta` and `.gff` files and add them to the `strains` and `tracks` bash arrays respectively in `installation/install_devcontainer.sh`. The JBrowse instance will be updated with the new assemblies automatically the next time the container is rebuilt, or by running `>Dev Containers: Rebuild`.

6. **Access the Viewer**

    Navigate to [http://localhost/jbrowse2](http://localhost/jbrowse2) in your web browser.

## Usage

**Getting Started**
Once you have succefully installed JBrowse and can access your instance in a web browser, you are ready to begin exploring different rhinovirus genomes!  
1. Opening JBrowse for the first time will prompt you to `Start a new session`. 
2. Select `Empty` to get started.

**Select a view to launch**
1. JBrowse supports a number of views to view genomic data in a convienent way. 
2. Linear Genome View allows for visualizing genome sequences along with their corresponding track annotations.
3. Linear Syntheny and Dotplot Views allow for visualizing pairwise sequence alignments calculated with `minimap2` for each genome pair using 5 different command line arguments. 
4. 

**Add the `MsaView` Plugin to view the alignments**  
 
1. Natigate and click on the `Tools ▼` dropdown  
2. Click on the `Plugin Store`
3. Find `MsaView` under the `Avalible plugins` and click ` + INSTALL `
4. Once installed, nativate to the `Add ▼` dropdown and select `Multiple Sequence Alignment view`
5. MsaView will prompt for a MSA File or URL. Select File, and choose the `all_assemblies.msa.fasta` file that was present in the clone git repository. `Open` to view.

