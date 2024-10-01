library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Usar esta biblioteca para `unsigned` e `to_integer`

entity MorseCode is
    port (
        SW    : in  std_logic_vector(2 downto 0); -- SW2-0 para selecionar a letra
        KEY0  : in  std_logic;                    -- Reset assíncrono
        KEY1  : in  std_logic;                    -- Botão para iniciar
        CLK   : in  std_logic;                    -- Clock
        LEDR0 : out std_logic                     -- LED para exibir o Morse
    );
end MorseCode;

architecture Behavioral of MorseCode is
    type MorseLengthsArray is array (0 to 7) of integer;
    
    -- Tabela de códigos Morse para letras A-H
    type MorseTable is array(0 to 7) of std_logic_vector(3 downto 0);
    
	 -- Lembrando que está sendo lido da direita para a esquerda
    signal morse_codes : MorseTable := (
        "0010", -- A
        "0001", -- B
        "0101", -- C
        "0001", -- D
        "0000", -- E
        "0100", -- F
        "0011", -- G
        "0000"  -- H
    );
    
    -- Array de tamanhos dos códigos Morse
    signal morse_lengths : MorseLengthsArray := (2, 4, 4, 3, 1, 4, 3, 4);

    signal current_code : std_logic_vector(3 downto 0);
    signal bit_index : integer := 0;
    signal pulse_counter : integer := 0;
    signal pulse_duration : integer := 0; -- 0.5s ou 1.5s
    signal pause_duration : integer := 25000000; -- Pausa de 0.5s entre símbolos
    signal state : std_logic_vector(1 downto 0) := "00"; -- Estados da FSM
    signal led_on : std_logic := '0'; -- Estado do LED
    signal active : boolean := false; -- Controle de execução
begin

    process (CLK, KEY0)
    begin
        if (KEY0 = '0') then
            -- Reset assíncrono
            bit_index <= 0;
            LEDR0 <= '0';
            pulse_counter <= 0;
            state <= "00"; -- Estado inicial
            active <= false; -- Desativar a execução no reset
        elsif rising_edge(CLK) then
            if (KEY1 = '0') and (not active) then
                -- Ativar o processo Morse ao pressionar KEY1
                active <= true;
                state <= "00";
            end if;

            if (active) then
                case state is
                    -- Estado "00": Carregar o código Morse
                    when "00" =>
                        current_code <= morse_codes(to_integer(unsigned(SW))); -- Conversão correta
                        bit_index <= 0;
                        pulse_counter <= 0;
                        state <= "01"; -- Avançar para exibir o primeiro símbolo

                    -- Estado "01": Exibir o ponto ou traço
                    when "01" =>
                        if (bit_index < morse_lengths(to_integer(unsigned(SW)))) then
                            if (current_code(bit_index) = '0') then
                                pulse_duration <= 25000000; -- Ponto (0.5s)
                            else
                                pulse_duration <= 75000000; -- Traço (1.5s)
                            end if;
                            
                            if (pulse_counter < pulse_duration) then
                                LEDR0 <= '1'; -- Acender o LED
                                pulse_counter <= pulse_counter + 1;
                            else
                                LEDR0 <= '0'; -- Apagar o LED ao fim do tempo do ponto ou traço
                                pulse_counter <= 0;
                                state <= "10"; -- Ir para o estado de pausa
                            end if;
                        else
                            -- Fim da sequência Morse
                            active <= false; -- Desativar a execução ao final da sequência
                            state <= "00"; -- Voltar ao estado inicial
                        end if;

                    -- Estado "10": Pausa entre os símbolos
                    when "10" =>
                        if (pulse_counter < pause_duration) then
                            pulse_counter <= pulse_counter + 1;
                        else
                            pulse_counter <= 0;
                            bit_index <= bit_index + 1; -- Avançar para o próximo bit da sequência
                            state <= "01"; -- Voltar para o estado de exibição do próximo símbolo
                        end if;

                    when others =>
                        state <= "00"; -- Estado padrão (segurança)
                end case;
            end if;
        end if;
    end process;
end Behavioral;

