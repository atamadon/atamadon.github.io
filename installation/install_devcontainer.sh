#!/bin/bash
# Must use bash, will not work with POSIX/Bourne shell /bin/sh

# Install brew package manager
yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install JBrowse
sudo npm install -g @jbrowse/cli

# Install additional dependencies
sudo apt update && sudo apt install wget unzip minimap2 muscle apache2 -y
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

# This script allows you to add multiple assemblies and tracks to JBrowse simply
# ADD LINKS TO ASSEMBLIES TO THE strains AND tracks ARRAYS TO VIEW IN JBROWSE
strains=(
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/835/GCF_002816835.1_ASM281683v1/GCF_002816835.1_ASM281683v1_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/855/GCF_002816855.1_ASM281685v1/GCF_002816855.1_ASM281685v1_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/872/325/GCF_000872325.1_ViralProj27901/GCF_000872325.1_ViralProj27901_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/885/GCF_002816885.1_ASM281688v1/GCF_002816885.1_ASM281688v1_genomic.fna.gz"
)
tracks=(
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/835/GCF_002816835.1_ASM281683v1/GCF_002816835.1_ASM281683v1_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/855/GCF_002816855.1_ASM281685v1/GCF_002816855.1_ASM281685v1_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/872/325/GCF_000872325.1_ViralProj27901/GCF_000872325.1_ViralProj27901_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/885/GCF_002816885.1_ASM281688v1/GCF_002816885.1_ASM281688v1_genomic.gff.gz"
)
assembly_names=()
assembly_files=()

# Loop over the different rhinovirus strains
for strain in ${strains[@]}; do
    wget $strain
    strain_file=$(basename $strain)
    assembly_file=${strain_file%.*.*}
    assembly_files+=($assembly_file)
    gunzip $strain_file
    unzipped_file=${strain_file%.gz}
    assembly_name=$(head -n 1 $unzipped_file | cut -d ' ' -f 1 | sed 's/>//')
    assembly_names+=($assembly_name)
    samtools faidx $unzipped_file
    sudo jbrowse add-assembly $unzipped_file --out $APACHE_ROOT/jbrowse2 --load copy --name $assembly_name
done

# Add tracks to JBrowse
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
for ((i=0; i<${#assembly_files[@]}; i++)); do
    for ((j=i+1; j<${#assembly_files[@]}; j++)); do
        assembly1=${assembly_files[i]}
        assembly2=${assembly_files[j]}
        minimap2 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}.paf
        minimap2 -x asm5 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_asm5.paf
        minimap2 -x map-ont ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_map-ont.paf
        minimap2 -x sr ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_sr.paf
        minimap2 -k 15 -w 5 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_sensitive.paf

        sudo jbrowse add-track ${assembly1}_${assembly2}.paf --assemblyNames ${assembly_names[j]},${assembly_names[i]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_asm5.paf --assemblyNames ${assembly_names[j]},${assembly_names[i]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_map-ont.paf --assemblyNames ${assembly_names[j]},${assembly_names[i]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_sr.paf --assemblyNames ${assembly_names[j]},${assembly_names[i]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_sensitive.paf --assemblyNames ${assembly_names[j]},${assembly_names[i]} --out $APACHE_ROOT/jbrowse2 --load copy
    done
done

# Create MSA
for assembly in ${assembly_files[@]}; do
    cat ${assembly}.fna >> all_assemblies.fasta
done
muscle -in all_assemblies.fasta -out /workspaces/atamadon.github.io/all_assemblies.msa.fasta

sudo jbrowse text-index --out $APACHE_ROOT/jbrowse2