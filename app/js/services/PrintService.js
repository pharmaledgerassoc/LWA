const { jsPDF } = window.jspdf

/**
 *
 * @type {{margins: number}}
 */

const defaultLayoutOpts = {
  margins: 10,
  orientation: 'portrait',
  unit: 'pt',
  format: "a4",
  defaultFontSize: 12,
  lineSpacing: 1.2
}

/**
 * @prop {jsPDF} _pdf
 */
class Layout {
  _columns;
  _pdf;
  _opts;

  _tracker;
  _scaleFactor = 1;

  _currentPage;
  _currentColumn;
  _currentHeight;

  /**
   *
   * @param {number} columns
   * @param {{}} [opts]
   */
  constructor(columns = 1, opts) {
    this._columns = Math.floor(Math.max(columns, 1));
    this._opts = Object.assign({}, opts || {}, defaultLayoutOpts)
  }

  /**
   * @description Resets the internal state for a new operation
   * @private
   */
  _begin(){
    this._currentPage = undefined;
    this._currentColumn = 1;
    this._currentHeight = 0;
    this._tracker = [];
    this._pdf = new jsPDF(this._opts);
    this._addPage(true);
  }

  /**
   * @description initializes a new page
   * @private
   */
  _addPage(countOnly = false){
    if(typeof this._currentPage === 'undefined'){
      this._currentPage = 0;
    } else {
      this._currentPage++;
    }
    if (!countOnly)
      this._pdf.addPage();
  }

  /**
   * @description parses the input text
   * @param {HTMLElement} el
   * @returns {string}
   * @private
   */
  _parseText(el){
    return el.textContent.replaceAll(/((?:\\n|\n)\s*)+/g, "\n").trim()
  }

  /**
   * @description checks if the font is loaded and if not loads it
   * @param {string} fontName
   * @param {"normal" | "bold"} style
   * @private
   */
  async _checkFont(fontName, style){
    let list = this._pdf.getFontList();
    if (!Object.keys(list).includes(fontName)){
      await this._loadFont(fontName, style);
    } else {

      const font = Object.keys(list).find(f => {
        f = f.name  || f;
        if (!f || !fontName)
          throw new Error("Should be impossible")
        return f.toLowerCase() === fontName.toLowerCase()
      });

      const types = list[font];
      if (!types.find(t => {
        if (!t || !style)
          throw new Error("Should be impossible")
        return t.toLowerCase() === style.toLowerCase()
      })){
        await this._loadFont(fontName, style);
      }
    }
  }

  async _loadFont(fontName, style){
    const fileName = `${fontName.replace(" ", "")}-${style.substring(0, 1).toUpperCase()}${style.substring(1, style.length)}`
    const fileUrl = `./fonts/${fileName}.ttf`;
    try {
      const font = new FontFace(fontName, `url('${fileUrl}')`)
      await font.load();
      document.fonts.add(font);
      this._pdf.addFont(fileUrl, fontName, style)
    } catch (e) {
      console.error(`Failed to load font ${fontName} under ${fileUrl}: ${e.message}`)
    }
  }

  _parseFontStyle(style, weight){
    if (!style) {
      switch (weight) {
        case "bold":
        case "normal":
          style = weight
          break;
        default:
          weight = parseInt(weight);
          // according to https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight
          style = isNaN(weight) || weight <= 500 ? "regular" : "bold";
      }
    }
    return style === "italic" ? "SemiBold" : style;
  }

  /**
   *
   * @param {string} fontSize in the <decimal><unit> format
   * where unit can be `pt`, `px`, `in`, `mm`, `cm`
   * @returns {number}
   * @private
   */
  _parseFontSize(fontSize){
    const regexp = /([\d.]+)(pt|px|in|mm|cm)/g
    const match = regexp.exec(fontSize);
    if (!match)
      return this._opts.defaultFontSize;
    const size = parseFloat(match[1]);
    if (isNaN(size))
      throw new Error("Could not parse font size");
    const units = match[2];
    switch (units){
      case "px":
        return Math.floor(size);
      default:
        throw new Error(`Unsupported font size unit: ${units}`)
    }
  }

  /**
   * @description applies the styles and calculates the block height accordingly
   * @param {HTMLElement} el
   * @param {string} [text]
   * @return {Promise<number>} the height the new block will add
   * @async
   * @private
   */
  async _style(el, text){
    const tag = el.tagName.toLowerCase()
    const style = getComputedStyle(el);
    let fontStyle;
    switch (tag){
      case "img":
        break;
      case "b":
        fontStyle = "bold";
      case "i":
        fontStyle = "italic";
      default:
        const font = style.fontFamily.replaceAll("\"", "");
        const fontSize = this._parseFontSize(style.fontSize);
        const fontWeight = style.fontWeight;
        this._pdf.setFontSize(fontSize);
        fontStyle = this._parseFontStyle(fontStyle, fontWeight)
        await this._checkFont(font, fontStyle);
        this._pdf.setFont(font, fontStyle);
        const {w, h} = this._pdf.getTextDimensions(text)
        return h;
    }
  }

  /**
   * @description evaluates the position in the page/column
   * @param {number} height
   * @private
   */
  _evaluateBlockPosition(height){
    if (this._currentHeight + height > this._pageHeight - 2 * this._opts.margins){
      if (this._currentColumn < this._columns)
        this._currentColumn++;
      else
        this._addPage()

      this._currentHeight = 0
    }
  }

  _incrementHeight(height){
    this._currentHeight = this._currentHeight + height
  }

  /**
   *
   * @param {HTMLElement} el
   * @private
   */
  async _addText(el){
    const text = this._parseText(el);
    const height = await this._style(el, text);
    this._evaluateBlockPosition(height)
    const xCoord = this._opts.margins + (this._columns - this._currentColumn) * this._pageWidth/this._columns;
    const yCoord = this._currentHeight;
    this._incrementHeight(height);
    this._pdf.text(text, xCoord, yCoord, { maxWidth: this._maxWidth });
  }

  /**
   *
   * @param {HTMLElement} el
   * @private
   */
  _addImage(el){
    this._pdf.addImage(this._opts.margins);
  }

  /**
   * @description Adds new text/image block to the layout
   * @param {HTMLElement} el
   */
  async addBlock(el){
    if (!this._tracker)
      this._begin()
    const tag = el.tagName.toLowerCase()
    switch (tag) {
      case "img":
        return this._addImage(el);
      default:
        return this._addText(el);
    }
  }

  /**
   * @description returns the pdfs uri to be used as a source in an iframe
   * @returns {string}
   */
  result(){
    this._tracker = undefined;
    return this._pdf.output('datauristring');
  }

  /**
   * @description returns the configured page height
   * @returns {number}
   * @private
   */
  get _pageHeight(){
    return this._pdf.internal.pageSize.getHeight()
  }

  /**
   * @description returns the configured page width
   * @returns {number}
   * @private
   */
  get _pageWidth(){
    return this._pdf.internal.pageSize.getHeight()
  }

  /**
   * @description returns the max width for a block considering page size, columns and margins
   * @returns {number}
   * @private
   */
  get _maxWidth(){
    return this._pageWidth / this._columns - 2 * this._opts.margins;
  }

}


export class PrintService {

  constructor() {
    this.printing = false;
    this.mode = "generated";
    const args = this.mode === "html" ? ['portrait', 'pt', 'a4'] : [];
    this.pdf = new jsPDF();
    this.pageHeight = this.pdf.internal.pageSize.getHeight()
    this.pageWidth = this.pdf.internal.pageSize.getWidth()
  }

  isPrinting(){
    return this.printing;
  }

  async _printByHtml(el, cfg){
    const updatedCfg = Object.assign({}, cfg, {
      image: {
        type: "jpeg",
        quality: 0.95
      },
      html2canvas: {
        windowHeight: this.pageHeight,
        windowWidth: this.pageWidth,
      }
    });
    this.pdf.html(el, updatedCfg);
  }

  /**
   * @summary extracts the leaflet content from the html
   * @description extracts all image nodes or ones with text content
   *
   * @param {HTMLElement} container
   * @param {HTMLElement[]} [accum]
   * @returns {HTMLElement[]}
   * @private
   */
  _extractLeafletContent(container, accum = []){
    const children = container.children;
    for(const child of children){
      if(child.textContent && !child.children.length)
        accum.push(child);
      else if (child.tagName.toLowerCase() === "img")
        accum.push(child)
      this._extractLeafletContent(child, accum);
    }
    return accum;
  }

  /**
   *
   * @param {HTMLElement} el
   * @param cfg
   * @returns {Promise<void>}
   * @private
   */
  async _printByBuilding(el, cfg) {
    const self = this;
    let result;
    const updatedCfg = Object.assign({}, cfg, {
      image: {
        type: "jpeg",
        quality: 0.95
      }
      // html2canvas: {
      //   windowHeight: this.pageHeight,
      //   windowWidth: this.pageWidth,
      // }
    });
    const elements = this._extractLeafletContent(el);
    const layout = new Layout();
    for (let i= 0; i <= elements.length - 1 ; i ++) {
      const elem = elements[i];
      try {
        await layout.addBlock(elem);
        console.log(`Processed block ${i}`)
      } catch (e) {
        console.error(`Failed to add block ${i}: ${e.message}`);
      }
    }
    result = layout.result();
    return result;
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
    return new Promise(async (resolve, reject) => {
      if (self.isPrinting())
        return console.log("Printing process already running");
      self.printing = true;
      const cfg = {
          callback: function(doc) {
            try {
              doc.save(`${fileName}.pdf`);
              self.printing = false;
            } catch (e){
              return reject(e)
            }
            resolve()
          },
          x: 12,
          y: 12
        }

      try {
        switch (this.mode){
          case "html":
            await this._printByHtml(el, cfg);
            break;
          case "generated":
            const pdfDataUri = await this._printByBuilding(el, cfg);
            const newTab = window.open();
            newTab?.document.write(`<iframe width='100%' height='100%' src='${pdfDataUri}'></iframe>`)
            break;
          default:
            throw new Error(`unsupported mode ${this.mode}`);
        }
      } catch (e) {
        return reject(e)
      } finally {
        self.printing = false;
      }
      resolve();
    })
  }

}