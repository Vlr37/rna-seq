package ro.biochim.aging.runner.transcriptomics

import java.io.{File => JFile}
import ro.biochim.aging.runner.core.BasicRunner


object DeNovoQuality extends BasicRunner(
  "/home/antonkulaga/rna-seq/workflows",
  "de-novo/quality","quality_de_novo.wdl") {
   //run("wilver.json")
  run("mother_kidney.json")
}
