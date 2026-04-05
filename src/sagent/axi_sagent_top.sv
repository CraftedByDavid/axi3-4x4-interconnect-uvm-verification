class axi_sagent_top extends uvm_agent;

	`uvm_component_utils(axi_sagent_top);

	axi_sagent sagth;

	function new(string name = "axi_sagent_top", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sagth=axi_sagent::type_id::create("sagth",this); 
	endfunction

endclass