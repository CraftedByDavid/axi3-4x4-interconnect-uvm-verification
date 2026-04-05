class axi_sagent_config extends uvm_object;

	virtual axi_sif svif;
	`uvm_object_utils(axi_sagent_config);

	uvm_active_passive_enum is_active;
	//uvm_active_passive_enum is_active = UVM_ACTIVE;

	function new(string name = "axi_sagent_config");
		super.new(name);
	endfunction

endclass