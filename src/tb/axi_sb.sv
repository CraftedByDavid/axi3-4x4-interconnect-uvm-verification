class axi_sb extends uvm_scoreboard;

	`uvm_component_utils(axi_sb);

	//uvm_tlm_analysis_fifo#(axi_mtrans) fmep;
	//uvm_tlm_analysis_fifo#(axi_strans) fsep;
	uvm_tlm_analysis_fifo#(axi_trans) fmep[];
	uvm_tlm_analysis_fifo#(axi_trans) fsep[];

	axi_env_config ecfgh;

	//axi_trans wth,rth,mth,sth;
	axi_trans wth,rth;
	axi_trans q1[$],q2[$];

	static int pkt_rcvd,pkt_cmpd;

	//master-0,slave-0
	covergroup cg_axi0_waddr;
		cp_awaddr : coverpoint wth.AWADDR {bins b_awaddr = {[32'h0000_0000:32'h00ff_ffff]};}
		cp_awburst : coverpoint wth.AWBURST {bins b_awburst[] = {[0:2]};}
		cp_awsize : coverpoint wth.AWSIZE {bins b_awsize[] = {[0:2]};}
		cp_awlen : coverpoint wth.AWLEN {bins b_awlen = {[0:15]};}
		cp_bresp : coverpoint wth.BRESP {bins b_bresp = {0};}
		cp_cross : cross cp_awburst,cp_awsize,cp_awlen;
	endgroup

	covergroup cg_axi0_wdata with function sample(int i);
		cp_wdata : coverpoint wth.WDATA[i] {bins b_wdata = {[0:32'hffff_ffff]};}
		cp_wstrb : coverpoint wth.WSTRB[i] {bins b_wstrb[] = {15,14,12,8,7,4,3,2,1};}
		cp_cross : cross cp_wdata,cp_wstrb;
	endgroup

	covergroup cg_axi0_raddr;
		cp_araddr : coverpoint rth.ARADDR {bins b_araddr = {[32'h0000_0000:32'h00ff_ffff]};}
		cp_arburst : coverpoint rth.ARBURST {bins b_arburst[] = {[0:2]};}
		cp_arsize : coverpoint rth.ARSIZE {bins b_arsize[] = {[0:2]};}
		cp_arlen : coverpoint rth.ARLEN {bins b_arlen = {[0:15]};}
		cp_cross : cross cp_arburst,cp_arsize,cp_arlen;
	endgroup

	covergroup cg_axi0_rdata with function sample(int i);
		cp_rdata : coverpoint rth.RDATA[i] {bins b_rdata = {[0:32'hffff_ffff]};}
		cp_rresp : coverpoint rth.RRESP[i] {bins b_rresp = {0};}
	endgroup

	//master-1,slave-1
	covergroup cg_axi1_waddr;
		cp_awaddr : coverpoint wth.AWADDR {bins b_awaddr = {[32'h0100_0000:32'h01ff_ffff]};}
		cp_awburst : coverpoint wth.AWBURST {bins b_awburst[] = {[0:2]};}
		cp_awsize : coverpoint wth.AWSIZE {bins b_awsize[] = {[0:2]};}
		cp_awlen : coverpoint wth.AWLEN {bins b_awlen = {[0:11]};}
		cp_bresp : coverpoint wth.BRESP {bins b_bresp = {0};}
		cp_cross : cross cp_awburst,cp_awsize,cp_awlen;
	endgroup

	covergroup cg_axi1_wdata with function sample(int i);
		cp_wdata : coverpoint wth.WDATA[i] {bins b_wdata = {[0:32'hffff_ffff]};}
		cp_wstrb : coverpoint wth.WSTRB[i] {bins b_wstrb[] = {15,14,12,8,7,4,3,2,1};}
		cp_cross : cross cp_wdata,cp_wstrb;
	endgroup

	covergroup cg_axi1_raddr;
		cp_araddr : coverpoint rth.ARADDR {bins b_araddr = {[32'h0100_0000:32'h01ff_ffff]};}
		cp_arburst : coverpoint rth.ARBURST {bins b_arburst[] = {[0:2]};}
		cp_arsize : coverpoint rth.ARSIZE {bins b_arsize[] = {[0:2]};}
		cp_arlen : coverpoint rth.ARLEN {bins b_arlen = {[0:11]};}
		cp_cross : cross cp_arburst,cp_arsize,cp_arlen;
	endgroup

	covergroup cg_axi1_rdata with function sample(int i);
		cp_rdata : coverpoint rth.RDATA[i] {bins b_rdata = {[0:32'hffff_ffff]};}
		cp_rresp : coverpoint rth.RRESP[i] {bins b_rresp = {0};}
	endgroup

	//master-2,slave-2
	covergroup cg_axi2_waddr;
		cp_awaddr : coverpoint wth.AWADDR {bins b_awaddr = {[32'h0200_0000:32'h02ff_ffff]};}
		cp_awburst : coverpoint wth.AWBURST {bins b_awburst[] = {[0:2]};}
		cp_awsize : coverpoint wth.AWSIZE {bins b_awsize[] = {[0:2]};}
		cp_awlen : coverpoint wth.AWLEN {bins b_awlen = {[0:11]};}
		cp_bresp : coverpoint wth.BRESP {bins b_bresp = {0};}
		cp_cross : cross cp_awburst,cp_awsize,cp_awlen;
	endgroup

	covergroup cg_axi2_wdata with function sample(int i);
		cp_wdata : coverpoint wth.WDATA[i] {bins b_wdata = {[0:32'hffff_ffff]};}
		cp_wstrb : coverpoint wth.WSTRB[i] {bins b_wstrb[] = {15,14,12,8,7,4,3,2,1};}
		cp_cross : cross cp_wdata,cp_wstrb;
	endgroup

	covergroup cg_axi2_raddr;
		cp_araddr : coverpoint rth.ARADDR {bins b_araddr = {[32'h0200_0000:32'h02ff_ffff]};}
		cp_arburst : coverpoint rth.ARBURST {bins b_arburst[] = {[0:2]};}
		cp_arsize : coverpoint rth.ARSIZE {bins b_arsize[] = {[0:2]};}
		cp_arlen : coverpoint rth.ARLEN {bins b_arlen = {[0:11]};}
		cp_cross : cross cp_arburst,cp_arsize,cp_arlen;
	endgroup

	covergroup cg_axi2_rdata with function sample(int i);
		cp_rdata : coverpoint rth.RDATA[i] {bins b_rdata = {[0:32'hffff_ffff]};}
		cp_rresp : coverpoint rth.RRESP[i] {bins b_rresp = {0};}
	endgroup

	//master-3,slave-3
	covergroup cg_axi3_waddr;
		cp_awaddr : coverpoint wth.AWADDR {bins b_awaddr = {[32'h0300_0000:32'h03ff_ffff]};}
		cp_awburst : coverpoint wth.AWBURST {bins b_awburst[] = {[0:2]};}
		cp_awsize : coverpoint wth.AWSIZE {bins b_awsize[] = {[0:2]};}
		cp_awlen : coverpoint wth.AWLEN {bins b_awlen = {[0:11]};}
		cp_bresp : coverpoint wth.BRESP {bins b_bresp = {0};}
		cp_cross : cross cp_awburst,cp_awsize,cp_awlen;
	endgroup

	covergroup cg_axi3_wdata with function sample(int i);
		cp_wdata : coverpoint wth.WDATA[i] {bins b_wdata = {[0:32'hffff_ffff]};}
		cp_wstrb : coverpoint wth.WSTRB[i] {bins b_wstrb[] = {15,14,12,8,7,4,3,2,1};}
		cp_cross : cross cp_wdata,cp_wstrb;
	endgroup

	covergroup cg_axi3_raddr;
		cp_araddr : coverpoint rth.ARADDR {bins b_araddr = {[32'h0300_0000:32'h03ff_ffff]};}
		cp_arburst : coverpoint rth.ARBURST {bins b_arburst[] = {[0:2]};}
		cp_arsize : coverpoint rth.ARSIZE {bins b_arsize[] = {[0:2]};}
		cp_arlen : coverpoint rth.ARLEN {bins b_arlen = {[0:11]};}
		cp_cross : cross cp_arburst,cp_arsize,cp_arlen;
	endgroup

	covergroup cg_axi3_rdata with function sample(int i);
		cp_rdata : coverpoint rth.RDATA[i] {bins b_rdata = {[0:32'hffff_ffff]};}
		cp_rresp : coverpoint rth.RRESP[i] {bins b_rresp = {0};}
	endgroup

	function new(string name = "axi_sb", uvm_component parent);
		super.new(name,parent);
		//master-0,slave-0
		cg_axi0_waddr=new();
		cg_axi0_wdata=new();
		cg_axi0_raddr=new();
		cg_axi0_rdata=new();
		//master-1,slave-1
		cg_axi1_waddr=new();
		cg_axi1_wdata=new();
		cg_axi1_raddr=new();
		cg_axi1_rdata=new();
		//master-2,slave-2
		cg_axi2_waddr=new();
		cg_axi2_wdata=new();
		cg_axi2_raddr=new();
		cg_axi2_rdata=new();
		//master-3,slave-3
		cg_axi3_waddr=new();
		cg_axi3_wdata=new();
		cg_axi3_raddr=new();
		cg_axi3_rdata=new();
		//fmep=new("fmep",this);
		//fsep=new("fsep",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_env_config)::get(this,"","axi_env_config",ecfgh))
			`uvm_fatal("SCOREBOARD","FAILED TO GET CONFIGURATION");
		fmep = new[ecfgh.num_magent];
		fsep = new[ecfgh.num_sagent];
		foreach(fmep[i])
			fmep[i] = new($sformatf("fmep[%0d]",i),this);
		foreach(fsep[i])
			fsep[i] = new($sformatf("fsep[%0d]",i),this);
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			fork
				begin
					fork:A
						begin
							fmep[0].get(wth);
							q1.push_back(wth);
							cg_axi0_waddr.sample();
							foreach(wth.WDATA[i]) 
							begin
								cg_axi0_wdata.sample(i);
							end
						end
						begin
							fmep[1].get(wth);
							q1.push_back(wth);
							cg_axi1_waddr.sample();
							foreach(wth.WDATA[i]) 
							begin
								cg_axi1_wdata.sample(i);
							end
						end
						begin
							fmep[2].get(wth);
							q1.push_back(wth);
							cg_axi2_waddr.sample();
							foreach(wth.WDATA[i]) 
							begin
								cg_axi2_wdata.sample(i);
							end
						end
						begin
							fmep[3].get(wth);
							q1.push_back(wth);
							cg_axi3_waddr.sample();
							foreach(wth.WDATA[i]) 
							begin
								cg_axi3_wdata.sample(i);
							end
						end
					join_any
					disable A;
					fork:B
						begin
							fsep[0].get(rth);
							q2.push_back(rth);
							cg_axi0_raddr.sample();
							foreach(rth.RDATA[i]) 
							begin
								cg_axi0_rdata.sample(i);
							end
						end
						begin
							fsep[1].get(rth);
							q2.push_back(rth);
							cg_axi1_raddr.sample();
							foreach(rth.RDATA[i]) 
							begin
								cg_axi1_rdata.sample(i);
							end
						end
						begin
							fsep[2].get(rth);
							q2.push_back(rth);
							cg_axi2_raddr.sample();
							foreach(rth.RDATA[i]) 
							begin
								cg_axi2_rdata.sample(i);
							end
						end
						begin
							fsep[3].get(rth);
							q2.push_back(rth);
							cg_axi3_raddr.sample();
							foreach(rth.RDATA[i]) 
							begin
								cg_axi3_rdata.sample(i);
							end
						end
					join_any
					disable B;					
				end
			join
			pkt_rcvd++;
			check_data(wth,rth);
		end
	endtask

	task check_data(axi_trans mth,axi_trans sth);
		if(mth.compare(sth))
		begin
			`uvm_info("SCOREBOARD","SUCCESS",UVM_NONE);
			`uvm_info("SCOREBOARD",$sformatf("MASTER_TRANSACTION :- \n %0s",mth.sprint()),UVM_NONE);
			`uvm_info("SCOREBOARD",$sformatf("SLAVE_TRANSACTION :- \n %0s",sth.sprint()),UVM_NONE);
			pkt_cmpd++;
		end
		else
		begin
			`uvm_info("SCOREBOARD","FAIL",UVM_NONE);
			`uvm_info("SCOREBOARD",$sformatf("MASTER_TRANSACTION :- \n %0s",mth.sprint()),UVM_NONE);
			`uvm_info("SCOREBOARD",$sformatf("SLAVE_TRANSACTION :- \n %0s",sth.sprint()),UVM_NONE);
		end
	endtask

	/*
	function void check_phase(uvm_phase phase);
		if(wth.compare(rth))
		begin
			`uvm_info("SCOREBOARD","SUCCESS",UVM_LOW);
			pkt_cmpd++;
		end
		else
			`uvm_info("SCOREBOARD","FAIL",UVM_LOW);
	endfunction
	*/

	function void report_phase(uvm_phase phase);
		real fc;
		`uvm_info("SCOREBOARD",$sformatf("NUMBER OF PACKETS RECEIVED = %0d",pkt_rcvd),UVM_NONE);
		`uvm_info("SCOREBOARD",$sformatf("NUMBER OF PACKETS COMPARED = %0d",pkt_cmpd),UVM_NONE);
		//master-0,slave-0
		`uvm_info("SCOREBOARD",$sformatf("AXI-0 WRITE ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi0_waddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-0 WRITE DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi0_wdata.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-0 READ ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi0_raddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-0 READ DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi0_rdata.get_coverage()),UVM_MEDIUM);
		//master-1,slave-1
		`uvm_info("SCOREBOARD",$sformatf("AXI-1 WRITE ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi1_waddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-1 WRITE DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi1_wdata.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-1 READ ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi1_raddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-1 READ DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi1_rdata.get_coverage()),UVM_MEDIUM);
		//master-2,slave-2
		`uvm_info("SCOREBOARD",$sformatf("AXI-2 WRITE ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi2_waddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-2 WRITE DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi2_wdata.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-2 READ ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi2_raddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-2 READ DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi2_rdata.get_coverage()),UVM_MEDIUM);
		//master-3,slave-3
		`uvm_info("SCOREBOARD",$sformatf("AXI-3 WRITE ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi3_waddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-3 WRITE DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi3_wdata.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-3 READ ADDRESS FUNCTIONAL COVERAGE = %0.2f",cg_axi3_raddr.get_coverage()),UVM_MEDIUM);
		`uvm_info("SCOREBOARD",$sformatf("AXI-3 READ DATA FUNCTIONAL COVERAGE = %0.2f",cg_axi3_rdata.get_coverage()),UVM_MEDIUM);
		fc = (cg_axi0_waddr.get_coverage() + cg_axi0_wdata.get_coverage() + cg_axi0_raddr.get_coverage() + cg_axi0_rdata.get_coverage() 
			  + cg_axi1_waddr.get_coverage() + cg_axi1_wdata.get_coverage() + cg_axi1_raddr.get_coverage() + cg_axi1_rdata.get_coverage()
			  + cg_axi2_waddr.get_coverage() + cg_axi2_wdata.get_coverage() + cg_axi2_raddr.get_coverage() + cg_axi2_rdata.get_coverage()
			  + cg_axi3_waddr.get_coverage() + cg_axi3_wdata.get_coverage() + cg_axi3_raddr.get_coverage() + cg_axi3_rdata.get_coverage())/16.0;
		`uvm_info("SCOREBOARD",$sformatf("TOTAL FUNCTIONAL COVERAGE = %0.2f",fc),UVM_MEDIUM);
	endfunction
	
endclass

/*
class axi_sb extends uvm_scoreboard;

	`uvm_component_utils(axi_sb);

	uvm_tlm_analysis_fifo#(axi_mtrans) fmep;
	uvm_tlm_analysis_fifo#(axi_strans) fsep;

	function new(string name = "axi_sb", uvm_component parent);
		super.new(name,parent);
		fmep=new("fmep",this);
		fsep=new("fsep",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass
*/