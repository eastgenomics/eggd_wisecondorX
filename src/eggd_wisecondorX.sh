#!/bin/bash

set -exo pipefail

main() {
    nb_cpus=$(grep -c ^processor /proc/cpuinfo)

    mkdir bamis
    mkdir npz
    mkdir ref
    mkdir -p ~/out/wisecondorx_output/

    dx-download-all-inputs --parallel

    if [[ "$create_ref" == false && "$variant_calling" == true ]]; then
        find ~/in/reference -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/ref
        ref=~/ref/${reference_name}
    fi

    sudo apt-get update
    sudo apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

    tar xzf Python-3.6.10.tgz
    cd Python-3.6.10
    ./configure
    make
    make install
    cd ..

    pip3 install -r requirements.txt

    sudo su - -c "R -e \"install.packages('jsonlite', version='1.5', repos='http://cran.rstudio.com/')\""
    sudo su - -c "R -e \"install.packages('BiocManager')\""
    sudo su - -c "R -e \"BiocManager::install('DNAcopy')\""

    # setup wisecondorX
    tar xzf WisecondorX-1.2.4.tar.gz
    cd WisecondorX-1.2.4
    python3 setup.py install
    cd ..

    if [[ "$convert_npz" == true ]]; then
        find ~/in/bam -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/bamis
        find ~/in/bai -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/bamis

        cd bamis

        # convert query bams into .npz files
        for bam in $(ls *bam); do
            # get sample id (sample name for validation --> Sample_n_stuff_blarg)
            sample_id=${bam%_*}
            WisecondorX convert ${bam}  ~/out/wisecondorx_output/${sample_id}.npz --binsize ${binsize_convert}
        done

        cd ..
    fi

    if [[ "$create_ref" == true ]]; then
        find ~/in/npz -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/npz
        # create reference
        WisecondorX newref ~/npz/*.npz ~/out/wisecondorx_output/reference.npz --cpus ${nb_cpus} --binsize ${binsize_newref} --yfrac 0.5
    fi

    if [[ "$variant_calling" == true ]]; then
        cd npz
        find ~/in/npz -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/npz

        if [[ "$create_ref" == true ]]; then
            ref=~/out/wisecondorx_output/reference.npz
        fi

        for npz in $(ls *npz); do
            sample_id=${npz%.*}
            # run CNV prediction
            if [[ -z "${sex}" ]]; then
                WisecondorX predict ${npz} ${ref} ~/out/wisecondorx_output/${sample_id} --plot --bed --gender ${sex}
            else
                WisecondorX predict ${npz} ${ref} ~/out/wisecondorx_output/${sample_id} --plot --bed
            fi
        done
    fi

    dx-upload-all-outputs --parallel
}
