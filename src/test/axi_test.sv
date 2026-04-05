class axi_test extends uvm_test;

	`uvm_component_utils(axi_test);

	axi_env envh;
	axi_env_config ecfgh;
	axi_magent_config mcfgh[];
	axi_sagent_config scfgh[];

	bit [1:0] maddr,saddr;

	function new(string name = "axi_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		ecfgh=axi_env_config::type_id::create("ecfgh");
		ecfgh.has_scoreboard=1;
		ecfgh.has_magent=1;		
		ecfgh.has_sagent=1;
		ecfgh.num_magent=4;
		ecfgh.num_sagent=4;
		ecfgh.magent_is_active=UVM_ACTIVE;
		ecfgh.sagent_is_active=UVM_ACTIVE;

		ecfgh.mcfgh=new[ecfgh.num_magent];
		ecfgh.scfgh=new[ecfgh.num_sagent];
		mcfgh=new[ecfgh.num_magent];
		scfgh=new[ecfgh.num_sagent];

		foreach(mcfgh[i])
		begin
			mcfgh[i]=axi_magent_config::type_id::create($sformatf("mcfgh[%0d]",i));
			if(!uvm_config_db#(virtual axi_mif)::get(this,"",$sformatf("axi_mif_%0d",i),mcfgh[i].mvif))
			begin
				`uvm_fatal("virtual axi_mif","FAILED TO GET CONTENTS");
			end
			mcfgh[i].is_active=UVM_ACTIVE;
			ecfgh.mcfgh[i]=mcfgh[i];	
		end		

		foreach(scfgh[i])
		begin
			scfgh[i]=axi_sagent_config::type_id::create($sformatf("scfgh[%0d]",i));					if(!uvm_config_db#(virtual axi_sif)::get(this,"",$sformatf("axi_sif_%0d",i),scfgh[i].svif))
			begin
				`uvm_fatal("virtual axi_mif","FAILED TO GET CONTENTS");
			end
			scfgh[i].is_active=UVM_ACTIVE;
			ecfgh.scfgh[i]=scfgh[i];	
		end

		uvm_config_db#(axi_env_config)::set(this,"*","axi_env_config",ecfgh);
		envh=axi_env::type_id::create("envh",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass

class fixed_test extends axi_test;

	`uvm_component_utils(fixed_test);

	fixed_mseq fmseq;

	function new(string name = "fixed_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		maddr=1;
		saddr=0;
		uvm_config_db#(bit [1:0])::set(this,"*","maddr",maddr);
		uvm_config_db#(bit [1:0])::set(this,"*","saddr",saddr);

		phase.raise_objection(this);
			fmseq=fixed_mseq::type_id::create("fmseq");
			//fmseq.start(envh.magt_toph[0].magth.mseqrh);
			for(int i=0;i<4;i++)
				fmseq.start(envh.magt_toph[i].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass

class incr_test extends axi_test;

	`uvm_component_utils(incr_test);

	incr_mseq imseq;

	function new(string name = "incr_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		maddr=2;
		saddr=1;
		uvm_config_db#(bit [1:0])::set(this,"*","maddr",maddr);
		uvm_config_db#(bit [1:0])::set(this,"*","saddr",saddr);

		phase.raise_objection(this);
			imseq=incr_mseq::type_id::create("imseq");
			//imseq.start(envh.magt_toph[0].magth.mseqrh);
			for(int i=0;i<4;i++)
				imseq.start(envh.magt_toph[i].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass

class wrap_test extends axi_test;

	`uvm_component_utils(wrap_test);

	wrap_mseq wmseq;

	function new(string name = "wrap_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		maddr=3;
		saddr=2;
		uvm_config_db#(bit [1:0])::set(this,"*","maddr",maddr);
		uvm_config_db#(bit [1:0])::set(this,"*","saddr",saddr);

		phase.raise_objection(this);
			wmseq=wrap_mseq::type_id::create("wmseq");
			//wmseq.start(envh.magt_toph[0].magth.mseqrh);
			for(int i=0;i<4;i++)
				wmseq.start(envh.magt_toph[i].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass

class random_test extends axi_test;

	`uvm_component_utils(random_test);

	random_mseq rmseq;

	function new(string name = "random_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		maddr=0;
		saddr=3;
		uvm_config_db#(bit [1:0])::set(this,"*","maddr",maddr);
		uvm_config_db#(bit [1:0])::set(this,"*","saddr",saddr);

		phase.raise_objection(this);
			rmseq=random_mseq::type_id::create("rmseq");
			//wmseq.start(envh.magt_toph[0].magth.mseqrh);
			for(int i=0;i<4;i++)
				rmseq.start(envh.magt_toph[i].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass


class extended_random_test1 extends axi_test;

	`uvm_component_utils(extended_random_test1);

	extended_random_mseq1 ermseq1;
	extended_random_mseq2 ermseq2;
	extended_random_mseq3 ermseq3;
	extended_random_mseq4 ermseq4;

	function new(string name = "extended_random_test1", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			ermseq1=extended_random_mseq1::type_id::create("ermseq1");
			ermseq2=extended_random_mseq2::type_id::create("ermseq2");
			ermseq3=extended_random_mseq3::type_id::create("ermseq3");
			ermseq4=extended_random_mseq4::type_id::create("ermseq4");

			ermseq1.start(envh.magt_toph[0].magth.mseqrh);
			ermseq2.start(envh.magt_toph[1].magth.mseqrh);
			ermseq3.start(envh.magt_toph[2].magth.mseqrh);
			ermseq4.start(envh.magt_toph[3].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass

class extended_random_test2 extends axi_test;

	`uvm_component_utils(extended_random_test2);

	extended_random_mseq5 ermseq5;
	extended_random_mseq6 ermseq6;
	extended_random_mseq7 ermseq7;
	extended_random_mseq8 ermseq8;

	function new(string name = "extended_random_test2", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			ermseq5=extended_random_mseq5::type_id::create("ermseq5");
			ermseq6=extended_random_mseq6::type_id::create("ermseq6");
			ermseq7=extended_random_mseq7::type_id::create("ermseq7");
			ermseq8=extended_random_mseq8::type_id::create("ermseq8");

			ermseq5.start(envh.magt_toph[0].magth.mseqrh);
			ermseq6.start(envh.magt_toph[1].magth.mseqrh);
			ermseq7.start(envh.magt_toph[2].magth.mseqrh);
			ermseq8.start(envh.magt_toph[3].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass

class extended_random_test3 extends axi_test;

	`uvm_component_utils(extended_random_test3);

	extended_random_mseq9 ermseq9;
	extended_random_mseq10 ermseq10;
	extended_random_mseq11 ermseq11;
	extended_random_mseq12 ermseq12;

	function new(string name = "extended_random_test3", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			ermseq9=extended_random_mseq9::type_id::create("ermseq9");
			ermseq10=extended_random_mseq10::type_id::create("ermseq10");
			ermseq11=extended_random_mseq11::type_id::create("ermseq11");
			ermseq12=extended_random_mseq12::type_id::create("ermseq12");

			ermseq9.start(envh.magt_toph[0].magth.mseqrh);
			ermseq10.start(envh.magt_toph[1].magth.mseqrh);
			ermseq11.start(envh.magt_toph[2].magth.mseqrh);
			ermseq12.start(envh.magt_toph[3].magth.mseqrh);
			#2500000;
		phase.drop_objection(this);
	endtask

endclass



