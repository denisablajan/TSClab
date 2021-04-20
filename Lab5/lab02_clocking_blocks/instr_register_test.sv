/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 *
 * SystemVerilog Training Workshop.
 * Copyright 2006, 2013 by Sutherland HDL, Inc.
 * Tualatin, Oregon, USA.  All rights reserved.
 * www.sutherland-hdl.com
 **********************************************************************/

module instr_register_test (tb_ifc io);  // interface port

  timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  int seed = 555;

  class Transaction;
  rand opcode_t     opcode;
  rand operand_t     operand_a, operand_b;
  address_t      write_pointer;
  
  constraint operandA_const{
	operand_a >= -15; 
	operand_a <= 15;
  }
  
  constraint operandB_const{
	operand_b >= 0; 
	operand_b <= 15;
  }
  
  constraint opcode_const{
	opcode >= 0; 
	opcode <= 7;
  }
  
  virtual function void  print_transaction();
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction
  endclass: Transaction

// -------------------------------- //

  class Transaction_ext extends Transaction;
    function void print_transaction();
	  $display("Clasa extinsa.");
	  super.print_transaction();
	endfunction
  endclass

  class Driver;
	virtual tb_ifc vifc;
	Transaction tr;
	Transaction_ext tr_ext;
	
	//coverage
	//cazuri
	//0. opcode == toate operatiile 
	//1. operand A = 31 de val, de la -15 la 15
	//2. operand B , 16 val de la 0 la 15
	//3. operand A < 0 -neg sau > 0 -poz
	//4. opcode == toate, cu operandA negativ
	//5. opcode = toate, cu operadn a pozitiv
	//6. opcode == toate, a sau b = 0
	//7. opcode == toate, operand a si b maxime (15 si 15)
	//8. a si b minime (-15 cu 0)
	//9. opcode == mod si div si operand b = 0

	covergroup inputs_measure;
		cov_0: coverpoint vifc.cb.opcode { 
			bins val_zero = {ZERO}; 
			bins val_passa = {PASSA};
			bins val_passb = {PASSB};
			bins val_add = {ADD};
			bins val_sub = {SUB};
			bins val_mult = {MULT};
			bins val_mod = {MOD};
			bins val_div = {DIV};
		}	
		cov_1: coverpoint vifc.cb.operand_a {
			bins val_op_a_neg [] = {[-14 : -1]};
			bins val_op_a_poz [] = {[1 : 14]};
			bins val_op_a_0      = {0};
			bins val_op_a_max    = {15};
			bins val_op_a_min    = {-15};
		}
		cov_2: coverpoint vifc.cb.operand_b {
			bins val_op_b []  = {[1 : 15]};
			bins val_op_b_0   = {0};
			bins val_op_b_max = {15};
		}
		cov_3: coverpoint vifc.cb.operand_a{
			bins val_poz = {[-15 : -1]};
			bins val_neg = {[0 :15]};
		}
		cov_4: cross cov_0, cov_3{
			ignore_bins i_poz = binsof(cov_3.val_poz);
		} 
		cov_5: cross cov_0, cov_3{
			ignore_bins i_neg = binsof(cov_3.val_neg);
		}
		cov_6_a_0: cross cov_0, cov_1, cov_2 {
			ignore_bins ign = binsof(cov_1.val_op_a_neg);
			ignore_bins ign1 = binsof(cov_1.val_op_a_poz);
			ignore_bins ign12 = binsof(cov_1.val_op_a_max);
			ignore_bins ign13 = binsof(cov_1.val_op_a_min);
		} 
		cov_6_b_0: cross cov_0, cov_1, cov_2 {
			ignore_bins ign1 = binsof(cov_2.val_op_b);
			ignore_bins ign2 = binsof(cov_2.val_op_b_max);
		} 
		cov_7: cross cov_0, cov_1, cov_2 {
			ignore_bins ign11 = binsof(cov_1.val_op_a_neg);
			ignore_bins ign12 = binsof(cov_1.val_op_a_poz);
			ignore_bins ign13 = binsof(cov_1.val_op_a_0);
			ignore_bins ign14 = binsof(cov_1.val_op_a_min);
			ignore_bins ign15 = binsof(cov_2.val_op_b);
			ignore_bins ign16 = binsof(cov_2.val_op_b_0);
		} 
		cov_8: cross cov_0, cov_1, cov_2 {
			ignore_bins ign11 = binsof(cov_1.val_op_a_neg);
			ignore_bins ign12 = binsof(cov_1.val_op_a_poz);
			ignore_bins ign13 = binsof(cov_1.val_op_a_max);
			ignore_bins ign14 = binsof(cov_1.val_op_a_0);
			ignore_bins ign15 = binsof(cov_2.val_op_b);
			ignore_bins ign16 = binsof(cov_2.val_op_b_max);
		}
		cov_9: cross cov_0, cov_2 {
			ignore_bins ign11 = binsof(cov_0.val_add);
			ignore_bins ign12 = binsof(cov_0.val_zero);
			ignore_bins ign13 = binsof(cov_0.val_sub);
			ignore_bins ign14 = binsof(cov_0.val_mult);
			ignore_bins ign15 = binsof(cov_0.val_passa);
			ignore_bins ign16 = binsof(cov_0.val_passb);
			ignore_bins ign17 = binsof(cov_2.val_op_b);
			ignore_bins ign18 = binsof(cov_2.val_op_b_max);
		}		

	endgroup

    function new(virtual tb_ifc vifc);
      this.vifc = vifc;
      tr = new();
	  tr_ext = new();
	  inputs_measure = new();
    endfunction 
	
	task resetSignals();
	  vifc.cb.write_pointer   <= 5'h00;      // initialize write pointer
      vifc.cb.read_pointer    <= 5'h1F;      // initialize read pointer
      vifc.cb.load_en         <= 1'b0;       // initialize load control line
      vifc.cb.reset_n         <= 1'b0;       // assert reset_n (active low)
	  repeat (2) @(vifc.cb) ;                // hold in reset for 2 clock cycles
      vifc.cb.reset_n         <= 1'b1;       // deassert reset_n (active low)
	endtask
	
	function assignSignals();
		static int temp = 0;
		vifc.cb.operand_a <= tr.operand_a;
        vifc.cb.operand_b <= tr.operand_b;
        vifc.cb.opcode <= tr.opcode;
        vifc.cb.write_pointer <= temp++;
		// inputs_measure.sample();
	endfunction
	
    task generate_transaction(); //un task consuma timp de simulare <- dif dintre functie si task
	
      $display("\nReseting the instruction register...");
	  resetSignals();

      $display("\nWriting values to register stack...");
      @vifc.cb vifc.cb.load_en <= 1'b1;      // enable writing to register
      repeat (6000) begin
        @(vifc.cb) tr.randomize();
		assignSignals();
        @(vifc.cb) tr.print_transaction();
		inputs_measure.sample();
      end
	  
	  tr = tr_ext;
	  
	  repeat (6000) begin
        @(vifc.cb) tr.randomize();
		assignSignals();
        @(vifc.cb) tr.print_transaction();
		inputs_measure.sample();
      end
      @vifc.cb vifc.cb.load_en <= 1'b0;      // turn-off writing to register

    endtask
  endclass: Driver

  // -------------------------------- //

  class Monitor;
    virtual tb_ifc vifc;

    function new(virtual tb_ifc vifc);
      this.vifc = vifc;
    endfunction

    function void print_results;
      $display("Read from register location %0d: ", vifc.cb.read_pointer);
      $display("  opcode = %0d (%s)", vifc.cb.instruction_word.opc, io.cb.instruction_word.opc.name);
      $display("  operand_a = %0d",   vifc.cb.instruction_word.op_a);
      $display("  operand_b = %0d\n", vifc.cb.instruction_word.op_b);
    endfunction: print_results

    task transaction_monitor();
      $display("\nReading back the same register locations written...");
      for (int i=0; i<=12; i++) begin
        @(this.vifc.cb) this.vifc.cb.read_pointer <= i;
        @(this.vifc.cb) this.print_results();
      end
    endtask
  endclass: Monitor

  // --------------------------------- //

  initial begin
    
    Driver driver;
    Monitor monitor;

    driver = new(io);
    monitor = new(io);

    driver.generate_transaction();
    monitor.transaction_monitor();

    @(io.cb) $finish;

  end

endmodule: instr_register_test