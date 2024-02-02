library(ggplot2)
url <- "https://caio-azevedo.github.io/oficina_futebol"

qrcode <- plot(qrcode::qr_code(url, ecl = 'M'), col = c('white', '#261373'))

ggsave("qrcode.png", plot = qrcode,
       width = 6, height = 6, dpi = 300)

