function fc_conLines(sys1,sys2)
% fc_conLines(sys1,sys2)
% connect the lines between sys1 (OPort)  and sys2 (IPort)
% if the lines already exist, then it  is NOT leading to an error
% however  connect the same line again to an other SS  might give problems
% if the line already exist


%B = 2(gcb,'Outport',false,1,0);for i=1:length(B), fprintf('%s   \n',get_param(B{i},'Name') ), end

% SS1
%sys1 = gcb
%sys1 = 'test3/SS_A'
SS1=get_param(sys1,'Name');
hOP = find_system(sys1,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Outport');
nOP = length(hOP);
for i = 1:nOP
    OPNames{i}  = get_param(hOP(i),'Name'); 
end

% SS2
%sys2 = gcb
%sys2 = 'test3/SS_A1'
SS2=get_param(sys2,'Name');
hIP = find_system(sys2,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Inport');
nIP = length(hIP);
for i = 1:nIP
    IPNames{i}  = get_param(hIP(i),'Name'); 
end

% show  IO Names  of the connection 2 SS
%OPNames
%IPNames
    
for io = 1:nOP  % 4
  for ii = 1:nIP  %5
     if  strcmp(OPNames{io}, IPNames{ii});
         %strOP = [SS1,'/',num2str(io)]
         %strIP = [SS2,'/',num2str(ii)]
         %add_line(gcs,strOP,strIP,'autorouting','on')
         %line_handles(c,:) = add_line(gcs,[SS1,'/',num2str(io)],[SS2,'/',num2str(ii)],'autorouting','on');
         try
             add_line(gcs,[SS1,'/',num2str(io)],[SS2,'/',num2str(ii)],'autorouting','on');
         catch
             continue;
         end
         break 
     end
  end
end    

  
  
 % 
% % hInPort = find_system(gcb,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Inport')