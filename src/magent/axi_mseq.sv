class axi_mseq extends uvm_sequence#(axi_trans);

	`uvm_object_utils(axi_mseq);

	bit [1:0] maddr,saddr;

	function new(string name = "axi_mseq");
		super.new(name);
	endfunction

endclass

class fixed_mseq extends axi_mseq;
	
	`uvm_object_utils(fixed_mseq);

	function new(string name = "fixed_mseq");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"maddr",maddr))
			`uvm_fatal("fixed_mseq","failed to get maddr");		
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"saddr",saddr))
			`uvm_fatal("fixed_mseq","failed to get saddr");

		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST==0;ARBURST==0;write_slave==maddr;read_slave==saddr;});
		finish_item(req);
	endtask

endclass

class incr_mseq extends axi_mseq;
	
	`uvm_object_utils(incr_mseq);

	function new(string name = "incr_mseq");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"maddr",maddr))
			`uvm_fatal("incr_mseq","failed to get maddr");		
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"saddr",saddr))
			`uvm_fatal("incr_mseq","failed to get saddr");

		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST==1;ARBURST==1;write_slave==maddr;read_slave==saddr;});
		finish_item(req);
	endtask

endclass

class wrap_mseq extends axi_mseq;
	
	`uvm_object_utils(wrap_mseq);

	function new(string name = "wrap_mseq");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"maddr",maddr))
			`uvm_fatal("wrap_mseq","failed to get maddr");		
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"saddr",saddr))
			`uvm_fatal("wrap_mseq","failed to get saddr");

		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST==2;ARBURST==2;write_slave==maddr;read_slave==saddr;});
		finish_item(req);
	endtask

endclass

class random_mseq extends axi_mseq;
	
	`uvm_object_utils(random_mseq);

	function new(string name = "random_mseq");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"maddr",maddr))
			`uvm_fatal("random_mseq","failed to get maddr");		
		if(!uvm_config_db#(bit [1:0])::get(null,get_full_name(),"saddr",saddr))
			`uvm_fatal("random_mseq","failed to get saddr");

		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {write_slave==maddr;read_slave==saddr;});
		finish_item(req);
	endtask

endclass

class extended_random_mseq1 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq1);

	constraint extended_aws1 {req.AWSIZE==2;}

	constraint extended_strobe_range1 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {15,14,7,4,2};
							}

	constraint extended_arb1 {req.ARBURST inside {1,2};}

	function new(string name = "extended_random_mseq1");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq2 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq2);

	constraint extended_aws2 {req.AWSIZE==2;}

	constraint extended_strobe_range2 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {15,14,7};
							}

	constraint extended_arb2 {req.ARBURST==2;}

	constraint extended_ars2 {req.ARSIZE==2;}

	function new(string name = "extended_random_mseq2");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq3 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq3);

	constraint extended_strobe_range3 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {14,7};
							}

	constraint extended_ars3 {req.ARSIZE==1;}

	function new(string name = "extended_random_mseq3");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq4 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq4);

	constraint extended_strobe_range4 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {14,7,4,1};
							}

	constraint extended_arb4 {req.ARBURST==1;}

	function new(string name = "extended_random_mseq4");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq5 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq5);

	constraint extended_strobe_range5 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {14,7};
							}

	constraint extended_arb5 {req.ARBURST inside {1,2};}

	function new(string name = "extended_random_mseq5");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq6 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq6);

	constraint extended_aws6 {req.AWSIZE==2;}

	constraint extended_strobe_range6 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {15,14,7,1};
							}

	constraint extended_arb6 {req.ARBURST==2;}

	function new(string name = "extended_random_mseq6");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq7 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq7);

	constraint extended_aws7 {req.AWSIZE==2;}

	constraint extended_strobe_range7 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {15,14,7};
							}

	function new(string name = "extended_random_mseq7");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq8 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq8);

	constraint extended_strobe_range8 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {7,2,1};
							}

	constraint extended_arb8 {req.ARBURST==1;}

	function new(string name = "extended_random_mseq8");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass
class extended_random_mseq9 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq9);

	constraint extended_aws9 {req.AWSIZE==2;}

	constraint extended_strobe_range9 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {15,14,7};
							}

	constraint extended_arb9 {req.ARBURST inside {1,2};}

	constraint extended_ars9 {req.ARSIZE==2;}

	function new(string name = "extended_random_mseq9");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq10 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq10);

	constraint extended_aws10 {req.AWSIZE==1;}

	constraint extended_strobe_range10 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {12,7,3};
							}

	function new(string name = "extended_random_mseq10");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq11 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq11);

	constraint extended_strobe_range11 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {14,7,3};
							}

	function new(string name = "extended_random_mseq11");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass

class extended_random_mseq12 extends axi_mseq;
	
	`uvm_object_utils(extended_random_mseq12);

	constraint extended_strobe_range12 {
    							foreach(req.WSTRB[i])
        							req.WSTRB[i] inside {8,7,4,1};
							}


	function new(string name = "extended_random_mseq12");
		super.new(name);
	endfunction

	task body();
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	endtask

endclass
/*
class axi_mseq extends uvm_sequence#(axi_mtrans);

	`uvm_object_utils(axi_mseq);

	function new(string name = "axi_mseq");
		super.new(name);
	endfunction

endclass
*/