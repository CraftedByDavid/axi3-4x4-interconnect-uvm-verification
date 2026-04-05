class axi_magent_config extends uvm_object;

	`uvm_object_utils(axi_magent_config);

	virtual axi_mif mvif;
	uvm_active_passive_enum is_active;
	//uvm_active_passive_enum is_active = UVM_ACTIVE;

	function new(string name = "axi_magent_config");
		super.new(name);
	endfunction

endclass