function AnnotatedBreathPlot_Beast(handles)

currentPREXIndex = handles.ValveTimes.PREXIndex{handles.V,handles.C}(handles.T)+handles.B;
currentPREX = handles.PREX(currentPREXIndex);
nextPREX = handles.PREX(currentPREXIndex+1);

currentFVopen = handles.ValveTimes.FVSwitchTimesOn{handles.V,handles.C}(handles.T);
currentFVclose = handles.ValveTimes.FVSwitchTimesOff{handles.V,handles.C}(handles.T);

goodtimes = handles.t>currentPREX+handles.plotwin(1) & handles.t<currentPREX+handles.plotwin(2);
cla
plot(handles.t(goodtimes)-currentPREX,handles.RRR(goodtimes),'k'); 
hold on;
plot(handles.t(goodtimes)-currentPREX,handles.resp(goodtimes),'color',[.8 .8 .8]); 

plot([currentFVopen-currentPREX currentFVopen-currentPREX], [min(handles.RRR(goodtimes)) max(handles.RRR(goodtimes))],'Color',[.2 .2 .7]);
plot([currentFVclose-currentPREX currentFVclose-currentPREX], [min(handles.RRR(goodtimes)) max(handles.RRR(goodtimes))],'Color',[.2 .2 .7]);
if handles.Correct(currentPREXIndex) == 0
    plot(currentPREX-currentPREX, 0, 's','Color',[.7 .2 .2]);
else
    plot(currentPREX-currentPREX, 0, 'o','Color',[1 0 0]);
end
if handles.Correct(currentPREXIndex+1) == 0
    plot(nextPREX-currentPREX, 0, 's','Color',[.7 .5 .5]);
else
    plot(nextPREX-currentPREX, 0, 'o','Color',[1 0 0]);
end





