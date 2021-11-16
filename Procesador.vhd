----------------------------------------------------------------------------------
-- Realizado por la catedra  Diseño Lógico (UNTREF) en 2015
-- Tiene como objeto brindarle a los alumnos un template del procesador requerido
-- Profesores Martín Vázquez - Lucas Leiva
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Proc is
    Port ( 
    	   clk : in  std_logic;
           rst : in  std_logic;
           proc_in : in  STD_LOGIC_VECTOR (7 downto 0);
           proc_out : out  std_logic_vector (7 downto 0));
end Proc;

architecture Beh_Proc of Proc is

-- ================
-- Declaración de los componentes utilziados

component regs 
    Port ( 
    	   regs_clk : in  std_logic;
           regs_rst : in  std_logic;
           regs_we : in  std_logic;
           regs_rd : in  std_logic_vector (3 downto 0);        
           regs_rs : in  std_logic_vector (3 downto 0);--aca deberia ir (7 downto 4);   
           regs_din : in  std_logic_vector (7 downto 0);
           regs_dout : out  std_logic_vector (7 downto 0)
           );
end component;

component alu port ( 
					 alu_op: in  std_logic_vector(2 downto 0);
           			 alu_a : in  std_logic_vector (7 downto 0);
           			 alu_b : in  std_logic_vector (7 downto 0);
           			 alu_s : out  std_logic_vector (7 downto 0)
           			 );
end component;

component rom_prog port (
						 rom_addr : in  std_logic_vector (6 downto 0);
						 rom_out : out  std_logic_vector (15 downto 0)
						 );
end component; 


component decode port (
					   decode_in : in  std_logic_vector (7 downto 0);
					   decode_reg_we : out  std_logic;
					   decode_out_we : out  std_logic;
					   decode_reg_a_we: out  std_logic;
					   decode_alu_op : out  std_logic_vector (2 downto 0);
					   decode_bus_sel : out  std_logic_vector (1 downto 0)
					   );
end component;

component program_counter port(
								pc_clk : in  std_logic;
								pc_out: out std_logic_vector (6 downto 0)
							    rst : in  std_logic
								);
end component; 

component regs_ir 
    Port ( 
    	   regs_ir_clk : in  std_logic;
           regs_ir_rst : in  std_logic;
           --regs_ir_we : in  std_logic;   VER DOND ESTA ESTE WE
           regs_ir_in : in  std_logic_vector (15 downto 0);
           regs_ir_out : out  std_logic_vector (15 downto 0)
           );
end component;

component regs_aux 
    Port ( 
    	   regs_aux_clk : in  std_logic;
           regs_aux_rst : in  std_logic;
           regs_aux_we : in  std_logic;   
           regs_aux_in : in  std_logic_vector (7 downto 0);
           regs_aux_out : out  std_logic_vector (7 downto 0)
           );
end component;

component mux3_8
	port ( 
		  mux_in_0 : in std_logic_vector(7 downto 0); 
		  mux_in_1 : in std_logic_vector(7 downto 0);
		  mux_in_2 : in std_logic_vector(7 downto 0);
		  mux_sel : in std_logic_vector(1 downto 0);		
		  mux_out : out std_logic_vector(7 downto 0)
		  );
end component;	



-- ================

-- ================
-- declaración de señales usadas 

-- Banco de registros
signal s_decode_regs_we : std_logic; -- senal para escribir en el banco de registro 
signal s_reg_ir_out : std_logic_vector(15 downto 0);
signal s_regs_dout : std_logic_vector(7 downto 0);

signal s_decode_alu_op : std_logic_vector(2 downto 0);
signal s_mux_out : std_logic_vector(7 downto 0);

signal s_reg_a_out : std_logic_vector(7 downto 0);

signal s_regout_in : std_logic_vector(7 downto 0);

signal s_pc_out : std_logic_vector(6 downto 0);
signal s_rom_out : std_logic_vector(15 downto 0);

signal s_decode_out_we : std_logic;
signal s_decode_reg_a_we : std_logic;
signal s_decode_bus_sel : std_logic_vector(1 downto 0);



-- signal ....

-- ================

begin

-- ================
-- Instaciacion de componentes utilziados

-- Banco de registros
c_regs:  regs port map (
						regs_clk => clk,
						regs_rst => rst,
						regs_we => s_decode_regs_we, 
					    regs_rd => s_reg_ir_out(3 downto 0),
					    regs_rs => s_reg_ir_out(7 downto 4), 
						regs_din => s_regout_in,
						regs_dout => s_regs_dout
						); -- hay que cpmpletar esta instanciación
-- La ALU
c_alu: alu port map (
					 alu_op => s_decode_alu_op,
           			 alu_a => s_mux_out,
           			 alu_b => s_reg_a_out,
           			 alu_s => s_regout_in
					);

-- La ROM de programa
c_rom: rom_prog port map (
						  rom_addr => s_pc_out,
						  rom_out => s_rom_out
						  );

-- El decodificador de la instrucción
c_decode: decode port map (
						    decode_in => s_reg_ir_out(15 downto 8),
					   		decode_reg_we => s_decode_regs_we,
					   		decode_out_we => s_decode_out_we,
					   		decode_reg_a_we => s_decode_reg_a_we,
					   		decode_alu_op => s_decode_alu_op,
					   		decode_bus_sel => s_decode_bus_sel
						   );

-- El program counter
c_program_counter: program_counter port map (
											 pc_clk => clk,
											 pc_out: => s_pc_out,
							    			 rst : => rst
											);

c_reg_ir: regs_ir port map (
							regs_ir_clk => clk,
           					regs_ir_rst => rst,
           					--regs_ir_we => ,VER DOND ESTA ESTE WE
           					regs_ir_in => s_rom_out, 
           					regs_ir_out => s_reg_ir_out
							);

c_reg_a: regs_aux port map(
						 	regs_aux_clk => clk,
           				 	regs_aux_rst => rst,
            			 	regs_aux_we => s_decode_reg_a_we,   
             			 	regs_aux_in => s_mux_out,
           				 	regs_aux_out => s_reg_a_out
						  );							 


c_reg_out: regs_aux port map(
						 	 regs_aux_clk => clk,
           				 	 regs_aux_rst => rst,
            			 	 regs_aux_we => s_decode_out_we,   
             			 	 regs_aux_in => s_regout_in,
           				 	 regs_aux_out => proc_out
							);

c_mux3_8: mux3_8 port map(
						   mux_in_0 => s_regs_dout, 
		  				   mux_in_1 => s_reg_ir_out(7 downto 0),
		  				   mux_in_2 => proc_in,
		  				   mux_sel => s_decode_bus_sel,		
		  				   mux_out => s_mux_out
						  );														
-- ================


-- ================
-- Descripción de mux que funciona como "bus"
-- controlado por bus_sel
	--case reg_a_we is
	-- when '0' s_mux_out   
	-- when '1' 
	-- when others; 

	--case regs_we is
	-- when '0' s_regout_in => alu_s
	-- when '1' s_regout_in => regs_din
	-- when others; 

-- ================


-- ================
-- Descripción de los almacenamientos
-- Los almacenamientos que se deben decribir aca son: 
-- <reg_a> 8 bits
-- <reg_out> de 8 bits
-- <pc> de 8 bits
-- <ir> de 16 bits

	process (clk, rst)
	
	begin
	     if (rst='1') then 
--		  	regs_aux_rst = '1';
		  elsif (rising_edge(clk)) then
		  
		  end if;
		  
	end process;
-- ================


end Beh_Proc;

