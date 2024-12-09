#!/bin/bash

# Install brew package manager
yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# # Install node
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
sudo apt update && sudo apt install wget unzip minimap2 apache2 -y
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

# Loop over the different rhinovirus strains
strains=(
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/835/GCF_002816835.1_ASM281683v1/GCF_002816835.1_ASM281683v1_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.fna.gz"
)
assembly_names=()
assembly_files=()
for strain in ${strains[@]}; do
    wget $strain
    strain_file=$(basename $strain)
    assembly_name=${strain_file%%.*}
    assembly_file=${strain_file%.*.*}
    assembly_names+=($assembly_name)
    assembly_files+=($assembly_file)
    gunzip $strain_file
    unzipped_file=${strain_file%.gz}
    echo "Unzipped file: $unzipped_file"
    samtools faidx $unzipped_file
    sudo jbrowse add-assembly $unzipped_file --out $APACHE_ROOT/jbrowse2 --load copy --name $assembly_name
done

tracks=(
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/835/GCF_002816835.1_ASM281683v1/GCF_002816835.1_ASM281683v1_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.gff.gz"
)

# Add tracks
for track in ${tracks[@]}; do
    wget $track
    track_file=$(basename $track)
    assembly_name=${track_file%%.*}
    gunzip $track_file
    unzipped_track=${track_file%.gz}
    sudo jbrowse sort-gff $unzipped_track > sorted_$unzipped_track
    echo "sorted tracks with jbrowse"
    bgzip sorted_$unzipped_track
    echo "compressed sorted tracks with bgzip"
    tabix sorted_$unzipped_track.gz
    echo "sorted compressed sorted tracks with tabix"
    sudo jbrowse add-track sorted_$unzipped_track.gz --out $APACHE_ROOT/jbrowse2 --load copy --assemblyNames $assembly_name
done

# Perform synteny calculations
minimap2 ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}.paf
sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy

sudo jbrowse text-index --out $APACHE_ROOT/jbrowse2