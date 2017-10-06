workflow quality_de_novo {

  File reads_1
  File reads_2


  call report as initial_report_1 {
      input:
          sampleName = basename(reads_1, ".fastq.gz"),
          file = reads_1
  }

  call report as initial_report_2 {
      input:
          sampleName = basename(reads_2, ".fastq.gz"),
          file = reads_2
  }

  call atropos_illumina_pe {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        threads = 8
  }

  call report as report_atropos_illumina_pe_1 {
      input:
          sampleName = basename(atropos_illumina_pe.out1, ".fastq.qz"),
          file = atropos_illumina_pe.out1
          }

  call report as report_atropos_illumina_pe_2 {
      input:
        sampleName = basename(atropos_illumina_pe.out2, ".fastq.qz"),
        file = atropos_illumina_pe.out2
        }

  call trimming_UrQt_pe {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        len = 36,
        q = 20
  }

  call report as report_trimming_UrQt_pe_1 {
      input:
          sampleName = basename(trimming_UrQt_pe.out1, ".fastq.qz"),
          file = trimming_UrQt_pe.out1
          }

  call report as report_trimming_UrQt_pe_2 {
      input:
        sampleName = basename(trimming_UrQt_pe.out2, ".fastq.qz"),
        file = trimming_UrQt_pe.out2
        }

  call trimming_UrQt_pe as trimming_atropos_UrQt_pe {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        len = 36,
        q = 20
  }

  call report as report_trimming_atropos_illumina_pe_1 {
      input:
          sampleName = basename(trimming_atropos_UrQt_pe.out1, ".fastq.qz"),
          file = trimming_atropos_UrQt_pe.out1
          }

  call report as report_trimming_atropos_illumina_pe_2 {
      input:
        sampleName = basename(trimming_atropos_UrQt_pe.out2, ".fastq.qz"),
        file = trimming_atropos_UrQt_pe.out2
        }

}


task report {

  String sampleName
  File file

  command {
    /opt/FastQC/fastqc ${file} -o .
  }

  runtime {
    docker: "quay.io/ucsc_cgl/fastqc@sha256:86d82e95a8e1bff48d95daf94ad1190d9c38283c8c5ad848b4a498f19ca94bfa"
  }

  output {
    File out = sampleName+"_fastqc.zip"
  }
}


task trimming_sickle_pe {

  File reads_1
  File reads_2
  Int len
  Int q

  command {
    sickle pe \
            -f ${reads_1} \
            -r ${reads_2} \
            -t sanger \
            -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq \
            -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq \
            -s unpaired.fastq \
            -q ${q} -l ${len}
  }

  runtime {
    docker: "asidorovj/sickle@sha256:933e4a880c58804248179c3819bb179c45ba86c85086d8435d8ab6cf82bca63c"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq"
  }
}

task atropos_illumina_pe {
  File reads_1
  File reads_2
  Int threads

  command {
    atropos trim \
      --aligner insert \
      -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG \
      -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT \
      -pe1 ${reads_1} \
      -pe2 ${reads_2} \
      -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq.gz \
      -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq.gz \
      --threads ${threads} \
      --correct-mismatches liberal
    }

    runtime {
        docker: "jdidion/atropos@sha256:a10547e2f6a05ca40819279f696b1afe9e7935dd4415b3f2a844190c2f38c820"
    }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.qz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.qz"
  }
}

task trimming_UrQt_pe {

  File reads_1
  File reads_2
  Int len
  Int q

  command {
    UrQt \
        --in ${reads_1} \
        --inpair ${reads_2} \
        --out ${basename(reads_1, ".fastq.gz")}_trimmed.fastq \
        --outpair ${basename(reads_2, ".fastq.gz")}_trimmed.fastq \
        --t ${q} --min_read_size ${len}
  }

  runtime {
    docker: "asidorovj/sickle@sha256:933e4a880c58804248179c3819bb179c45ba86c85086d8435d8ab6cf82bca63c"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.qz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.qz"
  }
}