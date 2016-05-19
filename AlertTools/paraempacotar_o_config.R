## para empacotar

# 1. Criar a pasta
system("rm -r ../alerta/")
system("mkdir ../alerta/")

# 2. copiar os arquivos de configuracao
system("cp -r ../config ../alerta/")
system("cp -r ../main ../alerta/")
system("cp -r ../report ../alerta/")

# 3. abrir o config.geral e trocar devtools por library(alertTools)
# se quiser adiantar, atualizar o path dos configs (tirando o ../)

#4. zipar
system("rm ../alerta.zip")
system("zip -r ../alerta.zip ../alerta")

#5. copíar para a pasta publica 
system("cp ../alerta.zip /home/Rpublic")

#6. copíar novo AlertTools para a pasta publica 
system("cp ../AlertTools_1.1.tar.gz /home/Rpublic")
