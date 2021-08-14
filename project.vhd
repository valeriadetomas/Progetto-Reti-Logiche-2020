----------------------------------------------------------------------------------
--
-- Prova Finale (Progetto di Reti Logiche)
-- Prof. William Fornaciari - Anno 2020/2021
--
-- Alessandra de Stefano (Codice Persona 10606454 Matricola 906918)
-- Valeria Detomas (Codice Persona 10615309 Matricola 912207)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity project_reti_logiche is
    port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end project_reti_logiche;
    
architecture Behavioral of project_reti_logiche is

	type state_type is (initial,  wait_data, save_dim, count_pixel, maxmindelta, controlla_soglia, new_value, write, wait_ram, wait_datadue, done);
    signal current_state, next_state: state_type;
    
    signal o_done_next, o_en_next, o_we_next : std_logic ;
    signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
    signal o_address_next : std_logic_vector(15 downto 0):= "0000000000000000";
    signal current_addr, next_addr: std_logic_vector(15 downto 0):= "0000000000000000";
    signal newfirst_addr, newfirst_addr_next : std_logic_vector(15 downto 0):= "0000000000000000";
    signal columns, columns_next: std_logic_vector(7 downto 0):= "00000000";
    signal rows, rows_next : std_logic_vector(7 downto 0) := "00000000"; 
    signal max, max_next: std_logic_vector(7 downto 0):= "00000000";
    signal min, min_next: std_logic_vector(7 downto 0):= "11111111";
    signal cont, cont_next: std_logic_vector(15 downto 0):= "0000000000000000"; 
    signal delta, delta_next : std_logic_vector(8 downto 0):= "000000000" ;
    signal tempvalue, tempvalue_next: std_logic_vector(15 downto 0):= "0000000000000000";
    signal shift, shift_next: std_logic_vector(7 downto 0):= "00000000";
    
    
begin 

process (i_clk, i_rst)
begin 
    
    if (i_rst ='1') then
                    
        current_state <= initial;
        
    elsif (i_clk'event and i_clk ='1') then  
           
        o_en <= o_en_next;
        o_we <= o_we_next;
        o_done <= o_done_next;
        o_data <= o_data_next;
        o_address <= o_address_next;
        current_addr <= next_addr;
        newfirst_addr <= newfirst_addr_next;
        columns <= columns_next;
        rows <= rows_next;
        max <= max_next;
        min <= min_next;
        cont <= cont_next;
        delta <= delta_next;
        tempvalue <= tempvalue_next;
        shift <= shift_next;
           
        current_state <= next_state;
            
    end if;
    
end process;


process(current_state, i_data, i_start, current_addr, columns, rows, max, min, cont, newfirst_addr, delta, tempvalue, shift)
begin
    
    o_en_next  <= '0';
    o_we_next <= '0';
    o_done_next <= '0';
    o_data_next <= "00000000";
    o_address_next <= "0000000000000000";
    
    next_addr <= current_addr;
    newfirst_addr_next <= newfirst_addr;
    columns_next <= columns;
    rows_next <= rows;
    max_next <= max;
    min_next <= min;
    cont_next <= cont;
    delta_next <= delta;
    tempvalue_next <= tempvalue;
    shift_next <= shift;
    
    next_state <= current_state;    
             
case current_state is
             
    when initial => 
       
        next_addr<= "0000000000000000";
        newfirst_addr_next <= "0000000000000000";
        columns_next <= "00000000";
        rows_next <= "00000000";
        max_next <= "00000000";
        min_next <= "11111111";
        cont_next <= "0000000000000000";
        delta_next <= "000000000";
        tempvalue_next <= "0000000000000000";
        shift_next <= "00000000";
       
        if (i_start='1') then 
            o_en_next <= '1';
            o_we_next <= '0';
            
            next_addr <= "0000000000000000";
            o_address_next <= "0000000000000000";
            
            next_state <= wait_data;
            
        end if;
        
    when wait_data =>
        o_en_next <= '1';
        o_we_next <= '0';
        o_address_next <= current_addr;
        next_state <= save_dim;
                      
    when save_dim =>
    
        o_en_next <= '1';
        o_we_next <= '0';
        
        next_addr <= std_logic_vector(unsigned(current_addr) +1 );
        o_address_next <= std_logic_vector(unsigned(current_addr) +1 );
        
        if (current_addr = "0000000000000000") then 
            columns_next <= i_data;
            next_state <= wait_data;	 
            
        elsif (current_addr = "0000000000000001") then 
            rows_next <= i_data;
            next_state <= count_pixel;
               
        end if;

        	
    when count_pixel => 
         
         o_en_next <= '1';
         o_we_next <= '0';
         next_addr <= "0000000000000010";
         o_address_next <= "0000000000000010";
              
         if (rows > 0) then
            cont_next <= std_logic_vector(unsigned(cont) + unsigned(columns));
            rows_next <= std_logic_vector(unsigned(rows) - "00000001");
            next_state <= count_pixel;
         else 
            newfirst_addr_next <= std_logic_vector(unsigned(cont) + "0000000000000010");
            next_state <= maxmindelta;
         end if;
 
                               
    when maxmindelta =>
        
        o_en_next <= '1';
        o_we_next <= '0';
           
        if (unsigned(current_addr) < unsigned(newfirst_addr)+1) then 
        
              next_addr <= std_logic_vector(unsigned(current_addr) + "0000000000000001");
              o_address_next <= std_logic_vector(unsigned(current_addr) + "0000000000000001");
              
              if (unsigned(i_data) > unsigned(max)) then 
                  max_next <= i_data ;
                  
              elsif(unsigned(i_data) < unsigned(min)) then 
                  min_next <= i_data;

              end if;
                
        else  
          
             delta_next <= std_logic_vector(unsigned(max) - unsigned(min) + "000000001");
        
             o_address_next <= "0000000000000010";
             next_addr <= "0000000000000010";
        
             next_state <= controlla_soglia;
                
       end if;


    when controlla_soglia =>
    
        o_en_next <= '1';
        o_we_next <= '0';
              
        if (to_integer(unsigned(delta)) = 1) then
             shift_next <= "00001000";
        elsif (to_integer(unsigned(delta)) = 256) then
             shift_next <= "00000000";
        elsif (to_integer(unsigned(delta)) >= 128) then 
             shift_next <= "00000001";
        elsif (to_integer(unsigned(delta)) >= 64) then
             shift_next <= "00000010";  
        elsif (to_integer(unsigned(delta)) >= 32) then 
             shift_next <= "00000011";
        elsif (to_integer(unsigned (delta)) >= 16) then 
             shift_next <= "00000100";
        elsif(to_integer(unsigned(delta)) >= 8) then
             shift_next <= "00000101";
        elsif(to_integer(unsigned(delta)) >= 4) then
             shift_next <= "00000110";
        elsif(to_integer(unsigned(delta)) >= 2 ) then 
             shift_next <= "00000111";
              
        end if;
        
        o_address_next <= "0000000000000010";
        next_addr <= "0000000000000010";
              
        next_state <= new_value;
              
              
    when new_value =>
             
       o_en_next <= '1';
       o_we_next <= '0';
       
     	
       if (unsigned(current_addr) < unsigned(newfirst_addr)) then
       
            tempvalue_next <= std_logic_vector(shift_left((("00000000" & unsigned(i_data)) - ("00000000" & unsigned(min))), to_integer(unsigned(shift)))); 
            o_address_next <= std_logic_vector(unsigned(newfirst_addr) + unsigned(current_addr) - 2);
          
            next_state <= write;                   
       else
            next_state <= done;
         
       end if;
    
                
    when write =>
             
       o_en_next <= '1';
       o_we_next <= '1';
       
       o_address_next <= std_logic_vector(unsigned(newfirst_addr) + unsigned(current_addr) - 2);
       next_addr <= std_logic_vector(unsigned (current_addr) +1);
        
       if (tempvalue(15 downto 8) = 0) then 
	    	o_data_next <= tempvalue(7 downto 0);
	    	next_state <= wait_ram;
       else
            o_data_next <= "11111111";
            next_state <= wait_ram;
       end if;
              
    when wait_ram => 
    
       o_en_next <= '1';
       o_we_next <= '0';
       o_address_next <= current_addr;
       
       next_state <=  wait_datadue;
       
    when wait_datadue =>
       o_en_next <= '1';
       o_we_next <= '0';
       o_address_next <= current_addr;
       next_addr <= current_addr;
       next_state <= new_value;
            
    when done => 
       if (i_start ='0') then
           o_done_next <= '0';
           next_state <= initial;
           
       else 
           o_done_next <= '1';
           o_en_next <= '0';
           o_we_next <= '0';
      end if;
                
    end case; 
            
  
      
end process;

end Behavioral;
