#!/bin/bash

main() {
    nb_cpus=$(grep -c ^processor /proc/cpuinfo)

    dx-download-all-inputs --parallel

    # setup wisecondorX
    tar xzf WisecondorX-1.2.4.tar.gz
    cd WisecondorX-1.2.4
    python setup.py install

    # convert query bams into .npz files
    for bam in $(ls *bam); do
        # get sample id (sample for validation for name Sample_n_stuff_blarg)
        sample_id=${bam%_*_*}
        WisecondorX convert ${bam} ${sample_id}.npz --binsize ${binsize}
    done

    if [[ "$create_ref" == true ]]; then
        # create reference
        WisecondorX newref /*.npz ~/out/wisecondorx_output/reference.npz --cpus ${nb_cpus}
    else
        for npz in $(ls *npz); do
            # run CNV prediction
            WisecondorX predict ${npz} ~/out/reference.npz ~/out/wisecondorx_output/output_id
        done
    fi

    dx-upload-all-outputs --parallel
}
