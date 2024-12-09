#!/bin/bash


# Install brew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# # Install node
# sudo apt install unzip
# # installs fnm (Fast Node Manager)
# curl -fsSL https://fnm.vercel.app/install | bash
# # activate fnm
# source ~/.bashrc
# # download and install Node.js
# fnm use --install-if-missing 20
# # verifies the right Node.js version is in the environment
# node -v # should print `v20.18.0`
# # verifies the right npm version is in the environment
# npm -v # should print `10.8.2`

sudo npm install -g @jbrowse/cli

# Install additional dependencies
sudo apt update && sudo apt install wget apache2 -y
brew install samtools htslib

# Start apache2
sudo service apache2 start
# be sure to replace the path with your actual true path!
export APACHE_ROOT='/var/www/html'

# Download and install JBrowse
mkdir ~/tmp
cd ~/tmp
jbrowse create output_folder
sudo mv output_folder $APACHE_ROOT/jbrowse2
sudo chown -R $(whoami) $APACHE_ROOT/jbrowse2

# Download Genome data
export FASTA_ROOT=https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens
wget $FASTA_ROOT/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz

gunzip Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz
mv Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa hg38.fa
samtools faidx hg38.fa

# Load genome into browser
jbrowse add-assembly hg38.fa --out $APACHE_ROOT/jbrowse2 --load copy

# Download Genome Annotations
export GFF_ROOT=https://ftp.ensembl.org/pub/release-110/gff3/homo_sapiens
wget $GFF_ROOT/Homo_sapiens.GRCh38.110.chr.gff3.gz
gunzip Homo_sapiens.GRCh38.110.chr.gff3.gz

# Sort Genome Annotations
jbrowse sort-gff Homo_sapiens.GRCh38.110.chr.gff3 > genes.gff
bgzip genes.gff
tabix genes.gff.gz

jbrowse add-track genes.gff.gz --out $APACHE_ROOT/jbrowse2 --load copy

jbrowse text-index --out $APACHE_ROOT/jbrowse2