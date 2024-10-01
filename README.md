# Aula 6 - Morse code

## Introdução

Nesta aula implementamos um tradutor de código morse, que traduzia letras do alfabeto para seu respectivo código morse. Para termos controle do tempo em segundos, dividimos o tempo de clock pelo clock do modelo utilizado na placa (neste caso a Ciclone V, que possui um clock de 50MHz). Assim, temos controle do tempo de um segundo, meio segundo, um segundo e meio, etc. Também fizemos uso de uma máquina de estados para determinarmos caso esteja sendo exibido um ponto ou linha no visor LED ou não. Ademais, utilizamos um vetor de sequencias de bits para representar cada letra. Foi determiando que 0 era o símbolo de um ponto e 1 o símbolo de uma linha. A funcionalidade foi implementada utilizando um shift register.
