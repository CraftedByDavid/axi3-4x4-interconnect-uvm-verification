class axi_sseqr extends uvm_sequencer#(axi_trans);

	`uvm_component_utils(axi_sseqr);

	function new(string name = "axi_sseqr", uvm_component parent);
		super.new(name,parent);
	endfunction

endclass

/*
class axi_sseqr extends uvm_sequencer#(axi_strans);

	`uvm_component_utils(axi_sseqr);

	function new(string name = "axi_sseqr", uvm_component parent);
		super.new(name,parent);
	endfunction

endclass
*/