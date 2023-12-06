% c_CeventsMCC = [];
% c_CMCCDataC = [];
% c_eventsNPX = [];
% c_OlfacMat = [];
% c_OM = [];
% c_StMCC = [];
% c_StNPX = [];
% endtimes = [];


c_CeventsMCC = [c_CeventsMCC;CeventsMCC+(sum(endtimes)*60*2000)];
c_CMCCDataC = [c_CMCCDataC,CMCCDataC{1}];
c_eventsNPX = [c_eventsNPX;eventsNPX + (sum(endtimes)*60*30000)];
c_OlfacMat = [c_OlfacMat;[OlfacMat,zeros(size(OlfacMat,1),1)+length(endtimes)+1]];
c_OM = [c_OM;[OM,zeros(size(OM,1),1)+length(endtimes)+1]];
c_StMCC = [c_StMCC;StMCC];
c_StNPX = [c_StNPX;StNPX];
endtimes = [endtimes,endtime];