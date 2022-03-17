#!/bin/bash

main() {

    echo "Value of bam: '${bam[@]}'"
    echo "Value of binsize: '$binsize'"

    for i in ${!bam[@]}
    do
        dx download "${bam[$i]}" -o bam-$i
    done

    tar xzf WisecondorX-1.2.4.tar.gz

    # convert query bams into .npz files
    for bam in $(ls *bam); do
        prefix=${bam#*.}
        WisecondorX convert $bam $prefix.npz
    done

    # create reference
    WisecondorX newref reference_input_dir/*.npz reference_output.npz

    # run CNV prediction
    WisecondorX predict test_input.npz reference_input.npz output_id

    for i in "${!something[@]}"; do
        dx-jobutil-add-output something "${something[$i]}" --class=array:file
    done
}
