class axi_env_config extends uvm_object;

	`uvm_object_utils(axi_env_config);

	//bit has_scoreboard = 1;
	//bit has_magent = 1;
	//bit has_sagent = 1;
	//int num_magent = 4;
	//int num_sagent = 4;
	//uvm_active_passive_enum magent_is_active = UVM_ACTIVE;
	//uvm_active_passive_enum sagent_is_active = UVM_ACTIVE;
	bit has_scoreboard;
	bit has_magent;
	bit has_sagent;
	int num_magent;
	int num_sagent;
	uvm_active_passive_enum magent_is_active;
	uvm_active_passive_enum sagent_is_active;
	axi_magent_config mcfgh[];
	axi_sagent_config scfgh[];

	function new(string name  = "axi_env_config");
		super.new(name);
	endfunction

endclass