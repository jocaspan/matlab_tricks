% **************************************************************************
% 0. Preface
% **************************************************************************


clc 
T = CEPADEFAInterfaceSheetPTCoorSG04S1;   %ToImprove:  Excel file name
%cur_comp = "MonNetDiag_Rx";             %ToImprove:  current component 
split_abc = split(gcs, '/');
cur_sys = split_abc{1,1};


% **************************************************************************
% 1. Excel: Importing the inputs
% **************************************************************************


inExcel_table = table;

for idx_i = 1 : height(T)
    if(table2array(T(idx_i,8))>0)
        inExcel_table = [inExcel_table; T(idx_i,:)];  
    else
       %T(4,T) = [];
    %T(:,"SelfAssessedHealthStatus") = [];                 
    end  
        
end

inExcel_table(:,"SourceSWModulePerInputSignal") = [];
inExcel_table(:,"ASILRating") = [];
inExcel_table(:,"ASILMax") = [];
inExcel_table(:,"OutputSignals") = [];
%inExcel_table(:,"signalAnalysisStatus") = [];
inExcel_table(:,"signalsAnalysed") = [];

inExcel_table(:,"IS_output") = [];

inExcel_table = renamevars(inExcel_table,"IS_input","Present");
inExcel_table.Present(:)= 0;

%inExcel_table = renamevars(inExcel_table, "SWModule", "Producer");
%inExcel_table = renamevars(inExcel_table, "InputSignals", "VariableName");

% [row,col] = size(inExcel_table);

%T = addvars(T,LastName,'Before',"Age");
% temp_table = table('Size',[row 1],'VariableTypes',"string");
%T = table('Size',[row 1],'VariableTypes',"char");
% temp_table.Properties.VariableNames = {'CurrentSystem'};

% temp_table.CurrentSystem(:) = cur_comp;
% inExcel_table = [temp_table inExcel_table];
% inExcel_table = addvars(inExcel_table, "CurrentSystem",'Before',"Producer");

% **************************************************************************
% 2. Excel: Importing the outputs
% **************************************************************************


outExcel_table  = T;
toDelete = T.IS_output <= 0;
outExcel_table(toDelete,:) = [];

outExcel_table(:,"ASILRating") = [];
outExcel_table(:,"InputSignals") = [];
outExcel_table(:,"SourceSWModulePerInputSignal") = [];
outExcel_table(:,"ASILMax") = [];

%outExcel_table(:,"signalAnalysisStatus") = [];

outExcel_table(:,"signalsAnalysed") = [];
outExcel_table(:,"IS_input") = [];

%outExcel_table(:,"IS_output") = [];
outExcel_table = renamevars(outExcel_table,"IS_output","Present");
outExcel_table.Present(:)= 0;

% [row,col] = size(outExcel_table);
% temp_table = table('Size',[row 1],'VariableTypes',"string");
% temp_table.Properties.VariableNames = {'CurrentSystem'};
% temp_table.CurrentSystem(:)= cur_comp;

% outExcel_table = [temp_table outExcel_table];

% *****************************************************************************
% 3. % Simulink: listing the existing inputs and outputs
% *****************************************************************************

%io_simu_cell = {};

%io_simu_cell = table('Size',[1 2],'VariableTypes',["cell", "cell"]);
%io_simu_cell = table(0, 0);

out_simu = {};
temp_list = table;



i_simu_cell = find_system(cur_sys,'SearchDepth',2,'BlockType','Inport');
o_simu_cell = find_system(cur_sys,'SearchDepth',2,'BlockType','Outport');

for idx_o = 1 : length(o_simu_cell)        
   o_simu_cell{idx_o,2} = 0;    
end
for idx_i = 1 : length(i_simu_cell)        
   i_simu_cell{idx_i,2} = 0;    
end


% *********************************
% 3.1 Listing the subsystems
% ********************************

subsystem_list = cell2table(find_system(cur_sys,'SearchDepth',2,'BlockType','SubSystem'), "VariableNames", "SubSystem_name");


% *****************************************************************************
% 4. OUTPORT: Finding outports / Adding missing / Deleting incorrect ports
% *****************************************************************************

% idx = ismember(T.Var1, myKeys);

ignored_cell = {};
duplicate_cell = {};
%outExcel_unique = unique(outExcel_table.SWModule);

[row, col] = size(outExcel_table);


for ind_exc = 1 : row
    
    %for ind = 1 : height(o_simu_table)
    for ind = 1 : height(o_simu_cell)
%     temp_abc = subsystem_list{ind,1}{1,1}
    
%         *********************
%         Finding similar module SWModule
%         *********************
        
        %if strfind(string(o_simu_table{ind,1}{1,1}), strip(string(outExcel_table.SWModule(ind_exc))))
        
        if strfind(string(o_simu_cell{ind,1}), strip(string(outExcel_table.SWModule(ind_exc))))          
            

            %split_abc =  strsplit(o_simu_table{ind,1}{1,1}, '/');
            split_abc =  strsplit(o_simu_cell{ind,1}, '/');
            
            if width(split_abc) > 3                
               %ignored_cell = vertcat(ignored_cell, o_simu_table{ind,1}{1,1})
               ignored_cell = vertcat(ignored_cell, o_simu_cell{ind,1})
               
            else
                if strcmp(string(split_abc{3}), outExcel_table.OutputSignals(ind_exc))
%                     *********************
%                     Module (SWModule) and variable(IOSignals) are present in simulink and excel
%                     *********************
                    if o_simu_cell{ind, 2} == 0                         
                        o_simu_cell{ind,2} = 1; 
                    else  
                        duplicate_cell = vertcat(duplicate_cell, o_simu_cell{ind,1});
                    end
                    if outExcel_table.Present(ind_exc)== 0
                        outExcel_table.Present(ind_exc)= 1;                        
                    else
                        duplicate_cell = vertcat(duplicate_cell, o_simu_cell{ind,1});
                    end
                    
                    break
                else
%                     if ind == height(o_simu_cell)
%                         o_simu_cell(ind, 2) = 0; % The Simulink port was not present in the excel file therefore should be deleted afterwards.
%                     end               
                    
                end         
                
            end          
        end        
    end
end

% *********************************
% Adding missing outports into simulink
% *********************************
for ind_exc = 1 : row
    if  outExcel_table.Present(ind_exc) == 0                      
        
        try
            add_block('simulink/Commonly Used Blocks/Out1',strcat(cur_sys,'/',string(outExcel_table.SWModule(ind_exc)),'/', string(outExcel_table.OutputSignals(ind_exc))));
            disp(['added outport block:' ,  strcat(cur_sys,'/',string(outExcel_table.SWModule(ind_exc)),'/', string(outExcel_table.OutputSignals(ind_exc)))]);              
                    
        catch
             disp(['A new block named ', strcat(string(outExcel_table.SWModule(ind_exc)), '/', string(outExcel_table.OutputSignals(ind_exc))), 'cannot be added'])
             continue;
         end
    end 
end

% *********************************
% Deliting outports from simulink
% *********************************
for ind = 1 : height(o_simu_cell)    
    if o_simu_cell{ind, 2} == 0
        disp '...' 
       %disp(string(strcat('To delete/check the outport: ', o_simu_cell(ind, 1))));
    end    
end



%add_block('simulink/Commonly Used Blocks/Out1','garbage/yourOutputName');
% set_param('connect_model/Gain','position',[220,80,260,120]);


% *****************************************************************************
% 5. INPORT: Finding inports / Adding missing / Deleting incorrect ports
% *****************************************************************************


for ind_exc = 1 : height(inExcel_table)
    
    %for ind = 1 : height(i_simu_table)
    for ind = 1 : height(i_simu_cell)
%     temp_abc = subsystem_list{ind,1}{1,1}
    
%         *********************
%         Finding similar module SWModule
%         *********************
        
        %if strfind(string(i_simu_table{ind,1}{1,1}), strip(string(inExcel_table.SWModule(ind_exc))))
        
        if strfind(string(i_simu_cell{ind,1}), strip(string(inExcel_table.SWModule(ind_exc))))          
            

            %split_abc =  strsplit(i_simu_table{ind,1}{1,1}, '/');
            split_abc =  strsplit(i_simu_cell{ind,1}, '/');
            
            if width(split_abc) > 3                
               %ignored_cell = vertcat(ignored_cell, i_simu_table{ind,1}{1,1})
               ignored_cell = vertcat(ignored_cell, i_simu_cell{ind,1})
               
            else
                %if strfind(string(split_abc{3}), inExcel_table.InputSignals(ind_exc))
                if strcmp(string(split_abc{3}), inExcel_table.InputSignals(ind_exc))
%                     *********************
%                     Module and variable are present in simulink and excel
%                     *********************
                    if i_simu_cell{ind, 2} == 0                         
                        i_simu_cell{ind,2} = 1; 
                    else  
                        duplicate_cell = vertcat(duplicate_cell, i_simu_cell{ind,1});
                    end
                    if inExcel_table.Present(ind_exc)== 0
                        inExcel_table.Present(ind_exc)= 1;                        
                    else
                        duplicate_cell = vertcat(duplicate_cell, i_simu_cell{ind,1});
                    end
                    
                    break
                else

                end         
                
            end          
        end        
    end
end

% *********************************
% Adding missing inports into simulink
% *********************************
for ind_exc = 1 : height(inExcel_table)
    if  inExcel_table.Present(ind_exc) == 0      
        try
            add_block('simulink/Commonly Used Blocks/In1',strcat(cur_sys,'/',string(inExcel_table.SWModule(ind_exc)),'/', string(inExcel_table.InputSignals(ind_exc))));
            disp(['added inport block:' ,  strcat(cur_sys,'/',string(inExcel_table.SWModule(ind_exc)),'/', string(inExcel_table.InputSignals(ind_exc)))]);              
        catch
            disp(['A new block named ', strcat(string(inExcel_table.SWModule(ind_exc)), '/', string(inExcel_table.InputSignals(ind_exc))), 'cannot be added'])
            continue;
        end
    end 
end

% *********************************
% Deleting/Logging inports from simulink
% *********************************
for ind = 1 : height(i_simu_cell)    
    if i_simu_cell{ind, 2} == 0
       disp '...' 
       %disp(string(strcat('To delete/check the inport: ', i_simu_cell(ind, 1))));
    end    
end


% *************************************
% 6. LINKING PORTS
% *************************************

i_simu_cell = {};
o_simu_cell = {};

i_simu_cell = find_system(cur_sys,'SearchDepth',2,'BlockType','Inport');
o_simu_cell = find_system(cur_sys,'SearchDepth',2,'BlockType','Outport');


for idx_i = 1 : height(i_simu_cell)
    for idx_o = 1 : height(o_simu_cell)
        split_i =  strsplit(i_simu_cell{idx_i,1}, '/');        
        split_o =  strsplit(o_simu_cell{idx_o,1}, '/');        
        
        if strfind(string(split_o{3}), string(split_i{3}))
            
            
            %****************
            
            fc_conLines(string(strcat(split_o(1), '/', split_o(2))), string(strcat(split_i(1), '/', split_i(2))))
            
%             sys1 = string(strcat(split_o(1), '/', split_o(2)));            
%             SS1=get_param(sys1,'Name');              
%             hOP = find_system(sys1,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Outport');
%             
%             for i = 1:length(hOP);
%                 OPNames{i}  = get_param(hOP(i),'Name'); 
%             end
%             
%             sys2 = string(strcat(split_i(1), '/', split_i(2)));
%             SS2=get_param(sys2,'Name');         
%             hIP = find_system(sys2,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Inport');
%             
%             for i = 1:length(hIP)
%                 IPNames{i}  = get_param(hIP(i),'Name'); 
%             end
% 
%             % show  IO Names  of the connection 2 SS
%             %OPNames
%             %IPNames
% 
%             for io = 1:length(hOP) % 4
%               for ii = 1:length(hIP)  %5
%                  if  strcmp(OPNames{io}, IPNames{ii})
%                      
%                      try
%                          add_line(gcs,[SS1,'/',num2str(io)],[SS2,'/',num2str(ii)],'autorouting','on')
%                      catch
%                          continue;
%                      end
%                      break 
%                  end
%               end
%             end    

        end

    end
end



% *********************************
% 99. POST DATA
% *********************************

if isempty(ignored_cell)
    
    disp('No nested subsystems were found')
else
    disp('TO CHECK if neested subsystems are allowed:')
    ignored_cell
end

if isempty(duplicate_cell)
    disp('No duplicate elements were found') 
else
    disp('TO CHECK if duplicate elements are allowed:')
    duplicate_cell    
end


clearvars temp_list B X temp_table T row col toDelete io_simu_cell split_abc ignored_cell ind idx_i idx_o


