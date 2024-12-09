#!/bin/bash

# Install brew package manager
yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install node
# installs fnm (Fast Node Manager)
curl -fsSL https://fnm.vercel.app/install | bash
# activate fnm
source ~/.bashrc
# download and install Node.js
fnm use --install-if-missing 20

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

# ADD LINKS TO ASSEMBLIES TO THIS ARRAY TO VIEW IN JBROWSE
strains=(
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/835/GCF_002816835.1_ASM281683v1/GCF_002816835.1_ASM281683v1_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/855/GCF_002816855.1_ASM281685v1/GCF_002816855.1_ASM281685v1_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/872/325/GCF_000872325.1_ViralProj27901/GCF_000872325.1_ViralProj27901_genomic.fna.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/885/GCF_002816885.1_ASM281688v1/GCF_002816885.1_ASM281688v1_genomic.fna.gz"
)
assembly_names=()
assembly_files=()
# Loop over the different rhinovirus strains
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
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/855/GCF_002816855.1_ASM281685v1/GCF_002816855.1_ASM281685v1_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/861/265/GCF_000861265.1_ViralProj15309/GCF_000861265.1_ViralProj15309_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/872/325/GCF_000872325.1_ViralProj27901/GCF_000872325.1_ViralProj27901_genomic.gff.gz"
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/816/885/GCF_002816885.1_ASM281688v1/GCF_002816885.1_ASM281688v1_genomic.gff.gz"
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
# minimap2 ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}.paf
# minimap2 -x asm5 ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}_asm5.paf
# minimap2 -x map-ont ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}_map-ont.paf
# minimap2 -x sr ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}_sr.paf
# minimap2 -k 15 -w 5 ${assembly_files[0]}.fna ${assembly_files[1]}.fna > ${assembly_files[0]}_${assembly_files[1]}_sensitive.paf

# sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy
# sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}_asm5.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy
# sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}_map-ont.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy
# sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}_sr.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy
# sudo jbrowse add-track ${assembly_files[0]}_${assembly_files[1]}_sensitive.paf --assemblyNames ${assembly_names[0]},${assembly_names[1]} --out $APACHE_ROOT/jbrowse2 --load copy

for ((i=0; i<${#assembly_files[@]}; i++)); do
    for ((j=i+1; j<${#assembly_files[@]}; j++)); do
        assembly1=${assembly_files[i]}
        assembly2=${assembly_files[j]}
        minimap2 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}.paf
        minimap2 -x asm5 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_asm5.paf
        minimap2 -x map-ont ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_map-ont.paf
        minimap2 -x sr ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_sr.paf
        minimap2 -k 15 -w 5 ${assembly1}.fna ${assembly2}.fna > ${assembly1}_${assembly2}_sensitive.paf

        sudo jbrowse add-track ${assembly1}_${assembly2}.paf --assemblyNames ${assembly_names[i]},${assembly_names[j]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_asm5.paf --assemblyNames ${assembly_names[i]},${assembly_names[j]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_map-ont.paf --assemblyNames ${assembly_names[i]},${assembly_names[j]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_sr.paf --assemblyNames ${assembly_names[i]},${assembly_names[j]} --out $APACHE_ROOT/jbrowse2 --load copy
        sudo jbrowse add-track ${assembly1}_${assembly2}_sensitive.paf --assemblyNames ${assembly_names[i]},${assembly_names[j]} --out $APACHE_ROOT/jbrowse2 --load copy
    done
done

sudo jbrowse text-index --out $APACHE_ROOT/jbrowse2