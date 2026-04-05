class axi_sagent extends uvm_agent;

	`uvm_component_utils(axi_sagent);

	axi_smon smonh;
	axi_sdrv sdrvh;
	axi_sseqr sseqrh;
	axi_sagent_config scfgh;
	
	function new(string name = "axi_sagent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db#(axi_sagent_config)::get(this,"","axi_sagent_config",scfgh))
		begin
			`uvm_fatal("axi_sagent_config","FAILED TO GET CONTENTS");
		end

		smonh=axi_smon::type_id::create("smonh",this);
		if(scfgh.is_active==UVM_ACTIVE)
		begin
			sdrvh=axi_sdrv::type_id::create("sdrvh",this);
			sseqrh=axi_sseqr::type_id::create("sseqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(scfgh.is_active==UVM_ACTIVE)
			sdrvh.seq_item_port.connect(sseqrh.seq_item_export);
	endfunction

	
endclass
