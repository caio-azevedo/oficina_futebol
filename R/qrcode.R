library(ggplot2)
url <- "https://caio-azevedo.github.io/oficina_futebol"

plot(qrcode::qr_code(url, ecl = 'M'),
               col = c('white', '#261373'))

dev.copy(png,"qrcode.png")
dev.off()

