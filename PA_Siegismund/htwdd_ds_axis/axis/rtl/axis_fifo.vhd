----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library htwdd_ds;
use htwdd_ds.integer_fcn_pkg.all;
use htwdd_ds.axis_pkg.all;
use htwdd_ds.axis_fifo_pkg.all;

entity axis_fifo is
  generic (
    fifo_depth_g   : positive := 32;
    async_rst_g    : boolean := false;
    active_rst_g   : std_logic
  );
  port (
    clk_i        : in  std_logic;
    rst_n_i      : in  std_logic;

    -- axis slave
    axis_s_i     : in  axis_m2s_b1i0d0u0_t;
    axis_s_o     : out axis_s2m_t;

    -- axis master
    axis_m_i     : in  axis_s2m_t;
    axis_m_o     : out axis_m2s_b1i0d0u0_t;

    -- data_count_o is the number of words in the FIFO.
    -- If there is a word in the output buffer (axis_m_o.tvalid=1) then
    -- this word is not regarded in data_count_o.
    -- I.e. if axis_m_o.tvalid=1 then axis_fifo actually stores (data_count_o+1) word.
    data_count_o : out std_logic_vector(unsigned_num_bits(fifo_depth_g)-1 downto 0)
  );
end axis_fifo;

architecture rtl of axis_fifo is
  
  constant addr_width_c  : natural := unsigned_num_bits(fifo_depth_g-1);
  constant count_width_c : natural := unsigned_num_bits(fifo_depth_g);
  constant data_width_c  : positive := 9;

  type reg_t is record
    fifo_cnt   : unsigned(count_width_c-1 downto 0);
    rd_adr     : unsigned(addr_width_c-1 downto 0);
    wr_adr     : unsigned(addr_width_c-1 downto 0);
    mem_wr_en  : std_logic;
    get_next   : std_logic;
    s_transfer : std_logic;
    m_transfer : std_logic;
    m_emptied  : std_logic;
    axis_m_out : axis_m2s_b1i0d0u0_t;
    axis_s_out : axis_s2m_t;
  end record;
  constant dflt_reg_c : reg_t := (
    fifo_cnt   => to_unsigned(0, count_width_c),
    rd_adr     => to_unsigned(0, addr_width_c),
    wr_adr     => to_unsigned(0, addr_width_c),
    mem_wr_en  => '0',
    get_next   => '0',
    s_transfer => '0',
    m_transfer => '0',
    m_emptied  => '0',
    axis_m_out => dflt_axis_m2s_b1i0d0u0_c,
    axis_s_out => dflt_axis_s2m_c
  );

  signal rin, r: reg_t := dflt_reg_c;
  signal rd_data_res : std_logic_vector(data_width_c-1 downto 0);

begin

  comb: process (r, axis_s_i, axis_m_i, rd_data_res)
    variable v: reg_t;
  begin
    v := r;

    v.m_transfer := v.axis_m_out.tvalid and axis_m_i.tready;      -- transfer at output (master) (i.e. output register is full)
    v.m_emptied  := (not v.axis_m_out.tvalid) or -- output (master) register is empty
                     v.m_transfer;               -- output (master) register is full and transfer at output (master)

    v.mem_wr_en := '0';

    -- v.get_next = 1 iff output buffer is (becomming) empty and there is at least one word in fifo (r.fifo_cnt > 0)
    if (r.fifo_cnt /= 0) then -- if (r.fifo_cnt > 0)
      v.get_next := v.m_emptied;
    else
      v.get_next := '0';
    end if;
    v.axis_m_out.tvalid := v.get_next or                                 -- transfer at slave i/f to output reg(s)
                          (v.axis_m_out.tvalid and not axis_m_i.tready); -- output register (master) full and no transfer at output

    if (v.get_next = '1') then -- read next data from fifo and provide at axis_m_o
      v.fifo_cnt   := v.fifo_cnt - 1;
      if (r.rd_adr /= fifo_depth_g-1) then -- if (r.rd_adr < fifo_depth_g-1)
        v.rd_adr     := r.rd_adr + 1;
      else
        v.rd_adr     := to_unsigned(0, addr_width_c);
      end if;
      v.axis_m_out.tdata  := rd_data_res(7 downto 0);
      v.axis_m_out.tstrb  := (others => '1');
      v.axis_m_out.tkeep  := (others => '1');
      v.axis_m_out.tlast  := rd_data_res(8);
    end if;

    v.axis_s_out.tready := '0';
    if (r.fifo_cnt /= fifo_depth_g) then -- if (r.fifo_cnt < fifo_depth_g) then
      v.axis_s_out.tready := '1';
    end if;
    v.s_transfer := axis_s_i.tvalid and v.axis_s_out.tready;
    if (v.s_transfer = '1') then
      v.mem_wr_en  := '1';
      v.fifo_cnt   := v.fifo_cnt + 1;
      if (r.wr_adr /= fifo_depth_g-1) then -- if (r.wr_adr < fifo_depth_g-1) then
        v.wr_adr := r.wr_adr + 1;
      else
        v.wr_adr := to_unsigned(0, addr_width_c);
      end if;
    end if;

    data_count_o <= std_logic_vector(r.fifo_cnt);

    axis_s_o        <= v.axis_s_out;
    axis_m_o        <= r.axis_m_out;

    rin <= v;
  end process;

  reg: process (rst_n_i, clk_i)
  begin
    if rst_n_i = active_rst_g and async_rst_g then
      r <= dflt_reg_c;
    else
      if rising_edge(clk_i) then
        if rst_n_i = active_rst_g and not async_rst_g then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process;

    ram_block : block
      type fifo_mem_t is array (0 to fifo_depth_g-1) of std_logic_vector(data_width_c-1 downto 0);
      signal fifo_mem    : fifo_mem_t := (others => (others => '0'));
      signal mem_rd_adr  : unsigned(addr_width_c-1 downto 0) := to_unsigned(0, addr_width_c);
      signal rd_data     : std_logic_vector(data_width_c-1 downto 0);
      signal wr_data     : std_logic_vector(data_width_c-1 downto 0);

    begin

      -- This solution might not be ressource optimal for fifo_depth_g = 2. (2 memory cells with each 9 bits and the wr_data register with 9 bits.)
      -- Possibly, one of those stores can be saved.

      mem_ctl : process (clk_i) is
      begin
        if rising_edge(clk_i) then
          if (rin.mem_wr_en = '1') then
            fifo_mem(to_integer(r.wr_adr)) <= axis_s_i.tlast & axis_s_i.tdata;
            wr_data                        <= axis_s_i.tlast & axis_s_i.tdata;
          end if;
          mem_rd_adr  <= rin.rd_adr; -- mem_rd_adr = r.rd_adr
        end if;
      end process mem_ctl;

      rd_data <= fifo_mem(to_integer(mem_rd_adr));

      -- Do not use rd_data when read and write address is equal and a write request occurs.
      -- Cf. Xilinx UG383 (v1.5) July 8, 2011, p. 15 (last item)
      mem_rd_data : process (r, rd_data, wr_data) is
      begin
        --if r.fifo_cnt = 0 then  -- not necessary, optimized away
        --  rd_data_res <= (others => '0'); -- fifo is empty: no data output
        --els
        if r.fifo_cnt = 1 then
          rd_data_res <= wr_data;  -- fifo contains one data sample: the one that has recently been written
        else
          rd_data_res <= rd_data;  -- read and write address are different even in the next cycle
        end if;
      end process;

    end block ram_block;

end rtl;
