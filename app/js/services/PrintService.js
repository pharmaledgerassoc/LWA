import {jsPDF} from "jspdf";

export class PrintService {

  constructor() {
    this.pdf = new jsPDF();
    this.printing = false;
  }

  isPrinting(){
    return this.printing;
  }

  /**
   * @summary prints the contents of an HTML element to PDF
   * @description generates a PDF from the contents of the provided HTML element
   * according to the defined template
   *
   * @param {HTMLElement} el
   * @param {string} fileName
   */
  async print(el, fileName = "leaflet" ){
    const self = this;
    if (self.isPrinting())
      return console.log("Printing process already running");
    self.printing = true;
    this.pdf.html(el, {
      callback: function(doc) {
        doc.save(`${fileName}.pdf`);
        self.printing = false;
      },
      x: 12,
      y: 12
    })
  }

}