function prof = plot_prof( info, filename, min )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Plots a profile of the results from simulation run.
%   info and filename can be found from call_results.m
%
%   The code was made on : January 4th, 2019
%   For assistance, conact: atritinger@gmail.com
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Basics:
%   This function returns the a profile plot of the user defined filename
%   set of results (U or V).
% 
%   
%   Inputs:
%       info = structure representing inputs 
%              (i.e. info = [10]    [0]    [5] means the following;
%               speed of 10 m/s, 0 degrees on-shore, at 5 meters depth)
%       filename = name of file being loaded in (U or V)
%              (i.e. the filenameU associated with the above info strcucture
%               is 113_110_105outU.txt)
%       min = how often, in minutes, user wants profiles printed
%
%   NOTE: info and filenameU or filenameV can be returned from call_results.m
%                       
%
%   Example:
%        prof =  plot_prof(info,filenameU,20)
%           would return : a plot of the results from the 113_110_105outU.txt
%                           plotted every 20 min.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dockit=@()set(gcf,'windowstyle','docked');  
    WTIME = 60;
    HH = 41;
    SIZE = 2.5;
    CC = parula;
    bigfont = 24;
    smallfont = 18;
    
    %Read in File, and set input values%
    RESULT = load(filename);
    % info = SPEED,DIR,DEPTH,UorV
    SPEED = info{1,1};
    DIR = info{1,2};
    DEPTH = info{1,3};
    temp = char(filename);
    UorV = temp(end-4);
    TIME = length(RESULT)/HH;
    DIV = min*(60/WTIME);
    hinc = DEPTH/(HH-1);
    
    counter = 0;
    
    %Organize Results%
    for it = 1:TIME
        for ih = 1:HH
            counter = counter + 1;
            PROF(it,ih) = RESULT(counter,1);
        end
    end
    
    
    counter = 0;
    y = 0:hinc:DEPTH;
    xzeros(1:HH) = zeros;
    %Plot Profile%
    prof = figure();
    hold on;
    for it = 1:DIV:TIME-1
        counter = counter + 1;
        if counter==64
            counter = 1;
        end
        x = PROF(it,:);
        plot(x,y','color',CC(counter,:),'linewidth',SIZE-.5);

    end
    x = PROF(TIME,:);
    plot(x,y,'color','k','linewidth',SIZE-.5);
    plot(xzeros,y,'--k','linewidth',SIZE-1);
    hold off;
    lgd = legend([num2str(min),' min intervals']);
    lgd.FontSize = smallfont;
    lgd.Location = 'best';
    f1 = gca;
    f1.LineWidth = 2.0;
    title(['Depth: ', num2str(DEPTH), ' m & Winds: ', num2str(SPEED),...
        ' m/s @ ', num2str(DIR),'^{\circ} Onshore']...
        ,'fontsize',bigfont);
    xlabel([UorV,' Velocity (m/s)'],'fontsize',smallfont,'color','b'); 
    ylabel('Depth (m)','fontsize',smallfont,'color','b');
    set(gca,'Ydir','reverse');
    grid on; grid minor; axis tight;
    dockit();
    print('-dpng',[num2str(SPEED),'_',num2str(DIR),'_',num2str(DEPTH),...
        UorV,'-PROF']);
end

