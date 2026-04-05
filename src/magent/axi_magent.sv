class axi_magent extends uvm_agent;

	`uvm_component_utils(axi_magent);

	axi_mmon mmonh;
	axi_mdrv mdrvh;
	axi_mseqr mseqrh;
	axi_magent_config mcfgh;
	
	function new(string name = "axi_magent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db#(axi_magent_config)::get(this,"","axi_magent_config",mcfgh))
		begin
			`uvm_fatal("axi_magent_config","FAILED TO GET CONTENTS");
		end

		mmonh=axi_mmon::type_id::create("mmonh",this);
		if(mcfgh.is_active==UVM_ACTIVE)
		begin
			mdrvh=axi_mdrv::type_id::create("mdrvh",this);
			mseqrh=axi_mseqr::type_id::create("mseqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(mcfgh.is_active==UVM_ACTIVE)
			mdrvh.seq_item_port.connect(mseqrh.seq_item_export);
	endfunction

	
endclass
