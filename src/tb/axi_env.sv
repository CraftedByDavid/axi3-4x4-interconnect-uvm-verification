class axi_env extends uvm_env;

	`uvm_component_utils(axi_env);

	axi_magent_config mcfgh[];
	axi_sagent_config scfgh[];
	axi_env_config ecfgh;

	axi_magent_top magt_toph[];
	axi_sagent_top sagt_toph[];
	axi_sb sbh;

	function new(string name  = "axi_env", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(axi_env_config)::get(this,"","axi_env_config",ecfgh))
		begin
			`uvm_fatal("axi_env_config","FAILED TO GET CONTENTS");
		end

		if(ecfgh.has_magent)
		begin
			magt_toph=new[ecfgh.num_magent];
			foreach(magt_toph[i])
			begin
				uvm_config_db#(axi_magent_config)::set(this,$sformatf("magt_toph[%0d]*",i),"axi_magent_config",ecfgh.mcfgh[i]);
				magt_toph[i]=axi_magent_top::type_id::create($sformatf("magt_toph[%0d]",i),this);
			end
		end

		if(ecfgh.has_sagent)
		begin
			sagt_toph=new[ecfgh.num_sagent];
			foreach(sagt_toph[i])
			begin
				uvm_config_db#(axi_sagent_config)::set(this,$sformatf("sagt_toph[%0d]*",i),"axi_sagent_config",ecfgh.scfgh[i]);
				sagt_toph[i]=axi_sagent_top::type_id::create($sformatf("sagt_toph[%0d]",i),this);
			end
		end

		if(ecfgh.has_scoreboard)
			sbh=axi_sb::type_id::create("sbh",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		if(ecfgh.has_magent && ecfgh.has_scoreboard)
			foreach(magt_toph[i])
				//magt_toph[i].magth.mmonh.mmp.connect(sbh.fmep.analysis_export);	
				magt_toph[i].magth.mmonh.mmp.connect(sbh.fmep[i].analysis_export);	
		if(ecfgh.has_sagent && ecfgh.has_scoreboard)	
			foreach(sagt_toph[i])
				//sagt_toph[i].sagth.smonh.smp.connect(sbh.fsep.analysis_export);
				sagt_toph[i].sagth.smonh.smp.connect(sbh.fsep[i].analysis_export);
	endfunction

endclass
