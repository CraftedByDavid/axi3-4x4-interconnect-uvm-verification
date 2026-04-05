class axi_sseq extends uvm_sequence#(axi_trans);

	`uvm_object_utils(axi_sseq);

	function new(string name = "axi_sseq");
		super.new(name);
	endfunction

endclass

/*
class axi_sseq extends uvm_sequence#(axi_strans);

	`uvm_object_utils(axi_sseq);

	function new(string name = "axi_sseq");
		super.new(name);
	endfunction

endclass
*/