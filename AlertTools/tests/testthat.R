library(testthat)
library(AlertTools)

test_check("AlertTools")

# listas de testes
# o alerta deve rodar mesmo que a cidade nao tenha casos - OK!
# mensagem de erro se houver incompatibilidade entre geocodigo, cidade, regional
# mensagem de erro/warning se  temperatura for 0

