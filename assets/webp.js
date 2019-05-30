var imagemin = require("imagemin"),           // The imagemin module.
    webp = require("imagemin-webp"),          // imagemin's WebP plugin.
    baseFolder = "./static/images",           // Change this line
    outputFolder = baseFolder,                // Output folder
    PNGImages = `${baseFolder}/*.png`,        // PNG images
    JPEGImages = `${baseFolder}/*.jpg`;       // JPEG images

imagemin([PNGImages], outputFolder, {
  plugins: [webp({
    lossless: true // Losslessly encode images
  })]
});

imagemin([JPEGImages], outputFolder, {
  plugins: [webp({
    quality: 65 // Quality setting from 0 to 100
  })]
});
