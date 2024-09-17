function fc_conLinesAdv(SS1,SS2)
% fc_conLinesAdv(SS1,SS2)
% advanced connection of Lines  between SS1 (source) and SS2 (destination)
% SS1 = source SS  (SS = SubSystem)
% SS2 = destination SS
% connect the lines between sys1 (OPort)  and sys2 (IPort)
% if the lines already exist, then it is NOT leading to an error
% Also a connection to another SS  starting from the same 'port/line' is OK
% To a destination port can only be written once, checked by
% (ssa1_iphline == -1 % No Line exist)

filnam = 'test4';
sys1 = [filnam,'/',SS1];
sys2 = [filnam,'/',SS2];

% SS1
%sys1 = 'test4/SS_A'
SS1 = get_param(sys1,'Name')
hOP = find_system(sys1,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Outport')
nOP = length(hOP);
for i = 1:nOP
    OPNames{i}  = get_param(hOP(i),'Name'); 
end

% SS2
%sys2 = 'test4/SS_A1'
SS2 = get_param(sys2,'Name')
hIP = find_system(sys2,'SearchDepth',1,'FindAll','on','FollowLinks','on','LookUnderMasks','all','BlockType','Inport')
nIP = length(hIP);
for i = 1:nIP
    IPNames{i}  = get_param(hIP(i),'Name'); 
end

% show  IO Names  of the connection 2 SS
%OPNames
%IPNames

% OLD  OK
% for io = 1:nOP  % 4
%   for ii = 1:nIP  %5
%      if  strcmp(OPNames{io}, IPNames{ii})
%          %strOP = [SS1,'/',num2str(io)]
%          %strIP = [SS2,'/',num2str(ii)]
%          %add_line(gcs,strOP,strIP,'autorouting','on')
%          try
%              add_line(gcs,[SS1,'/',num2str(io)],[SS2,'/',num2str(ii)],'autorouting','on')
%          catch
%              continue;
%          end
%          break 
%      end
%   end
% end    

% NEW Better 
%SS_A1_ph = get_param('test4/SS_A1', 'PortHandles');   % Destination SS
SS_A1_ph = get_param(sys2, 'PortHandles');   % Destination SS
for io = 1:nOP  % 4
  for ii = 1:nIP  %5
     ssa1_iphline = get_param(SS_A1_ph.Inport(ii), 'Line')
     if  strcmp(OPNames{io}, IPNames{ii}) && ssa1_iphline == -1 % no Line exist
         %try
         add_line(gcs,[SS1,'/',num2str(io)],[SS2,'/',num2str(ii)],'autorouting','on')
     else  %catch
         continue;
         %break;
     end
  end
end  


