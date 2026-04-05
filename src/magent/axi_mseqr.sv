class axi_mseqr extends uvm_sequencer#(axi_trans);

	`uvm_component_utils(axi_mseqr);

	function new(string name = "axi_mseqr", uvm_component parent);
		super.new(name,parent);
	endfunction

endclass

/*
class axi_mseqr extends uvm_sequencer#(axi_mtrans);

	`uvm_component_utils(axi_mseqr);

	function new(string name = "axi_mseqr", uvm_component parent);
		super.new(name,parent);
	endfunction

endclass
*/