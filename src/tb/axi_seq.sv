class axi_seq extends uvm_sequence#(axi_trans);

	`uvm_object_utils(axi_seq);

	function new(string name = "axi_seq");
		super.new(name);
	endfunction

endclass