
%{
Example usage: plotScalarResource("servicesMemoryUsage.csv","report.txt","Memory",3,3)
%}

function y = plotScalarResource(logfile, reportfile, elementName,tickStepX,tickStepY)
pkg load io

labels = csv2cell(logfile);
data = dlmread(logfile,',',0,1);
[rowCount, columnCount] = size(data);
xLabels = labels(1:rowCount-1,1:1);
yLabels = datestr(data(rowCount:rowCount,1:columnCount)./86400/1000000000 .+ datenum(1970,1,1));
tx = linspace (1, rowCount-1, rowCount-1)';
ty = linspace (1, columnCount, columnCount)';
figure;
surfc(tx,ty,data(1:rowCount-1,1:columnCount)')
h = gca();
caxis(h,[-30 80])
title([elementName " Usage over Time"]);
set(h, 'xtick', tx(1:tickStepX:rowCount-1));
set(h, 'ytick', ty(1:tickStepY:columnCount-1));
set(h, 'XTickLabel', strrep(xLabels(1:tickStepX:rowCount-1),'_','\_'));
set(h, 'YTickLabel', yLabels(1:tickStepY:columnCount-1,:));

%get statistical data
varianceData = sqrt(var(data(1:rowCount-1,1:columnCount)'));
meanData = mean(data(1:rowCount-1,1:columnCount)');
minimumData = min(data(1:rowCount-1,1:columnCount)');
maximumData = max(data(1:rowCount-1,1:columnCount)');

%plot variance
figure;
bar(varianceData);
title([elementName " Variance over Time"]);
h = gca();
set(h, 'xtick', tx(1:tickStepX:rowCount-1));
set(h, 'XTickLabel', strrep(xLabels(1:tickStepX:rowCount-1),'_','\_'));

%plot mean
figure;
bar(meanData);
title([elementName " Mean over Time"]);
h = gca();
set(h, 'xtick', tx(1:tickStepX:rowCount-1));
set(h, 'XTickLabel', strrep(xLabels(1:tickStepX:rowCount-1),'_','\_'));

fid = fopen(reportfile,'w');
%extract stats about the actual data
fprintf(fid,"A total of %i services with %i samples, recorded from %s to %s.\n\n",rowCount-1,columnCount-1,yLabels(1,:),yLabels(columnCount-1,:));

%extract services in descending order of their variance
[~,idx] = sort(varianceData, 'descend');
sortedVariance = varianceData(1,idx);
fprintf(fid,"--------------- Services sorted with Respect to their Variance of Resource Usage ---------------\n");
for i=1:rowCount-1
	 fprintf(fid,"%-70s: %-10f\%%\n", xLabels{idx(i)}, sortedVariance(i));
end

%extract services in descending order of their mean
[~,idx] = sort(meanData, 'descend');
sortedMean = meanData(1,idx);
fprintf(fid,"\n\n--------------- Services sorted with Respect to their Mean of Resource Usage ---------------\n");
for i=1:rowCount-1
	 fprintf(fid,"%-70s: %-10f\%%\n", xLabels{idx(i)}, sortedMean(i));
end

%extract services in descending order of their minimum
[~,idx] = sort(minimumData, 'descend');
sortedMinimum = minimumData(1,idx);
fprintf(fid,"\n\n--------------- Services sorted with Respect to their Minimum of Resource Usage ---------------\n");
for i=1:rowCount-1
	 fprintf(fid,"%-70s: %-10f \%%\n", xLabels{idx(i)}, sortedMinimum(i));
end

%extract services in descending order of their maximum
[~,idx] = sort(maximumData, 'descend');
sortedMaximum = maximumData(1,idx);
fprintf(fid,"\n\n--------------- Services sorted with Respect to their Maximum of Resource Usage ---------------\n");
for i=1:rowCount-1
	 fprintf(fid,"%-70s: %-10f\%%\n", xLabels{idx(i)}, sortedMaximum(i));
end

%calculate the total used resource amount
maxValue = 100;
totalResourceUse = sum(sum(data(1:rowCount-1,1:columnCount)))/(maxValue*(rowCount-1)*(columnCount-1));
fprintf(fid,"\n\nA total of %f\%% of the available resource was used during the recording period.\n",totalResourceUse);


fclose(fid);

end