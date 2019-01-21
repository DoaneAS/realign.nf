#! /usr/bin/env nextflow

// Copyright (C) 2018 IARC/WHO

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

params.help = null

log.info ""
log.info "-------------------------------------------------------------------------"
log.info "    mskilab wgs realignments v1: From BAM to hg38 Callable BAM       "
log.info "-------------------------------------------------------------------------"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "-------------------------------------------------------------------------"
log.info ""

if (params.help)
{
    log.info "---------------------------------------------------------------------"
    log.info "  USAGE                                                 "
    log.info "---------------------------------------------------------------------"
    log.info ""
    log.info "nextflow run [OPTIONS]"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--sampleindex            CSV FILE              sampleID,sampleType(tumor/normal),bamPath"
    log.info "--output_dir             OUTPUT FOLDER         Output for gVCF file"
    exit 1
}


//
// Parameters Init
//
params.input         = null
params.output_dir    = "results_nopairedatac"
params.gatk_exec     = null
params.dbsnp         = null
params.onekg         = null
params.mills         = null
params.interval_list = null
params.sampleindex         = null
params.bwa_index    =    '/gpfs/commons/home/doanea-934/DB/hg38/hg38-noalt/BWAIndex'
//
// Parse Input Parameters
//

//ubam_ch   = Channel
//			.fromPath(params.input)
//			.map { input -> tuple(input.baseName, input) }




index = file(params.sampleindex)
output    = file(params.output_dir)
bwa_index = params.bwa_index
        //GATK      = params.gatk_exec
        //ref       = file(params.ref_fasta)
        //interList = file(params.interval_list)
        //ref_dbsnp = file(params.dbsnp)
        //ref_1kg   = file(params.onekg)
        //ref_mills = file(params.mills)
        //ref_dict  = ref.parent / ref.baseName + ".dict"
        //ref_in    = ref.parent / ref.baseName + ".fasta.fai"
        //ref_amb   = ref.parent / ref.baseName + ".fasta.amb"
        //ref_ann   = ref.parent / ref.baseName + ".fasta.ann"
        //ref_bwt   = ref.parent / ref.baseName + ".fasta.bwt"
        //ref_pac   = ref.parent / ref.baseName + ".fasta.pac"
        //ref_sa    = ref.parent / ref.baseName + ".fasta.sa"


inputbam = Channel
.from(index.readLines())
.map { line ->
       def list = line.split(',')
       def Sample = list[0]
       def samplepath = file(list[2])
       def sampletype = list[1]
       def message = '[INFO] '
       log.info message
       [ Sample, sampletype, samplepath ]
}




//
//  Process unmap
//

    process speedyseq {
        tag { bamfile }
        publishDir "$output/$Sample/$sampletype", mode: 'copy'
        module 'speedseq'

        //cpus 12
        cpus 24
        executor 'sge'
            //memory { 5.GB * task.attempt }
        penv 'smp'
        errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
        clusterOptions "-l h_vmem=6G -l h_rss=240G -R y -l h_rt=96:00:00 -cwd -V"

        input:
        set Sample, sampletype, file(bamfile) from inputbam

        output:
        set val(file_tag_new), file("${file_tag_new}.bam") into bam_files
        file("${file_tag_new}.bam.bai") into bai_files

        shell:
        file_tag = bamfile.getBaseName()
        file_tag_new = file_tag+'.realign'

        '''
        speedseq realign -t 20 -M 36 /gpfs/commons/home/doanea-934/DB/hg38/hg38-noalt/BWAIndex/genome.fa !{bamfile}
        '''

    }




