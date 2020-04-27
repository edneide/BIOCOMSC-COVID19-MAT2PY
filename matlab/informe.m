function [xp,yp,ep] = informe(A,data,deaths,name,pop,guardar,yF)

x = (1:length(data))';
y = data;
y(isnan(y)) = 0;
z = deaths;
z(isnan(z)) = 0;
if sum(y>100)>3 && max(y)>200
    
    xx = x(y>100);
    T0 = find(y>50,1,'first')-10;
    yy = y(y>100);
    
    if length(xx)>15
        xx = xx(end-14:end);
        yy = yy(end-14:end);
    end
    
    ft = fittype(['K*exp(-log(K/' num2str(yy(1)) ')*exp(-a*(x-' num2str(xx(1)) ')))'], 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions('Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Levenberg-Marquardt';
    opts.Display = 'Off';
    opts.StartPoint = [max(y(end),1000) 0.2];
    %opts.Lower = [y(end) 0];
    %opts.Upper = [1e6 0.5];
    try
        [fitresult, gof] = fit( xx, yy, ft, opts );
    catch
        opts.Algorithm = 'Trust-Region';
        opts.Display = 'Off';
        opts.StartPoint = [max(y(end),1000) 0.2];
        opts.Lower = [y(end) 0];
        opts.Upper = [1e6 0.5];
        [fitresult, gof] = fit( xx, yy, ft, opts );
    end
    xp = x(end)+1;
    if length(xx)>6
        xp = [xp;x(end)+2];
        if length(xx)>9
            xp = [xp;x(end)+3];
            if length(xx)>12
                xp = [xp;x(end)+4];
                if length(xx)>15
                    xp = [xp;x(end)+5];
                end
            end
        end
    end
    Npred = length(xp);
    yp = fitresult(xp);
    yp = max(yp,y(end));
    ep = predint(fitresult,xp,0.99,'observation','off');
    np = yp(1)-y(end);
    en = ep(1,2)-yp(1);
    for ii = 2:length(xp)
        np = [np; yp(ii)-yp(ii-1)];
        en = [en; sqrt((ep(ii,2)-yp(ii))^2+(ep(ii-1,2)-yp(ii-1))^2)];
    end
    en = [en en];
    en(:,1) = min(en(:,1),np);
    ep(:,1) = max(ep(:,1),y(end));
    ep(:,1) = yp-ep(:,1);
    ep(:,2) = max(ep(:,2),y(end));
    ep(:,2) = ep(:,2)-yp;
    Nvect = length(x(y>100))-5;
    tvect = x(y>100);
    if Nvect>0
        tvect = tvect(6:end);
    end
    Kvect = zeros(Nvect,3);
    avect = zeros(Nvect,3);
    FR = fitresult;
    
    for k = 1:Nvect
        disp(k);
        xx = x(y>100);
        yy = y(y>100);
        x1 = xx(1:(5+k));
        y1 = yy(1:(5+k));
        if length(x1)>16
            x1 = x1(end-15:end);
            y1 = y1(end-15:end);
        end
        ft = fittype(['K*exp(-log(K/' num2str(yy(1)) ')*exp(-a*(x-' num2str(xx(1)) ')))'], 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions('Method', 'NonlinearLeastSquares' );
        opts.Algorithm = 'Levenberg-Marquardt';
        opts.Display = 'Off';
        opts.StartPoint = [max(yy(end),1000) 0.2];
        %opts.Lower = [y(end) 0];
        %opts.Upper = [1e6 0.5];
        try 
            [fitresult, gof] = fit( x1, y1, ft, opts );
        catch
            opts.Algorithm = 'Trust-Region';
            opts.Display = 'Off';
            opts.StartPoint = [max(y(end),1000) 0.2];
            opts.Lower = [y(end) 0];
            opts.Upper = [1e6 0.5];
            [fitresult, gof] = fit( x1, y1, ft, opts );
        end
        Kvect(k,1) = fitresult.K;
        avect(k,1) = fitresult.a;
        cf = confint(fitresult);
        cf(1,1) = max(cf(1,1),y1(end));
        cf(1,2) = max(cf(1,2),0);
        Kvect(k,2) = Kvect(k,1)-cf(1,1);
        Kvect(k,3) = cf(2,1) - Kvect(k,1);
        avect(k,2) = avect(k,1)-cf(1,2);
        avect(k,2) = min(avect(k,2),avect(k,1));
        avect(k,3) = cf(2,2) - avect(k,1);
    end
    
    %eliminar = Kvect(:,1)>1e6 | Kvect(:,2)>1e6 | avect(:,1)>0.25 | avect(:,2)>0.25;
    %Kvect(eliminar,:)=[];
    %avect(eliminar,:)=[];
    %tvect(eliminar) = [];
    %Nvect = size(Kvect,1);
    
    if max(z)>10
        nwd = z;
        deathrate = 0.01;
        i18 = 1/deathrate*nwd(1:end-1);
        i19 = 1/deathrate*nwd(2:end);
        estimated = 0.5*(i18+i19);
    else
        estimated = [];
    end
    
    t = xx(1):0.1:100;
    f1 = figure(1);
    clf
    
    yyaxis left
    plot(x,y,'o','MarkerFaceColor',[18 10 143]/255,'MarkerSize',2,'Color',[18 10 143]/255)
    hold on
    errorbar(xp,yp,ep(:,1),ep(:,2),'o','MarkerFaceColor',[220 20 60]/255,'MarkerSize',4,'Color',[220 20 60]/255)
    plot(t,FR(t),'--','Color',[254 168 119]/255,'linewidth',1.2)
    plot(x,y,'o','MarkerFaceColor',[18 10 143]/255,'MarkerSize',3,'Color',[18 10 143]/255)
    errorbar(xp,yp,ep(:,1),ep(:,2),'o','MarkerFaceColor',[220 20 60]/255,'MarkerSize',4,'Color',[220 20 60]/255)
    ax1 = gca;
    ax1.TickDir = 'out';
    ax1.Box = 'off';
    ax1.LineWidth=2;
    ylabel('Cumulative confirmed cases')
    ax1.FontSize = 14;
    ax1.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax1.XTick = XT;
    ax1.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax1.XMinorTick='on';
    ax1.TickLength= [0.02 0.04];
    ax1.XColor = [0 0 0];
    ax1.YColor = [0 0 0];
    yt = ax1.YTick;
    ax1.YTick = yt;
    ax1.YTickLabel = yt;
    Lim = ax1.YLim;
    
    yyaxis right
    plot(-1,-1,'ok')
    xlabel('Time (day)')
    ylabel('Cumulative cases per 10^5')
    ax1.YAxis(2).Limits = Lim;
    limlim = Lim(2)/pop*1e5;
    se = [.1 .2 .5 1 2 5 10 20 50 100 200 500 1e3 2e3 5e3 1e4 2e4];
    llim = zeros(1,17);
    for ise = 1:17
        lim = 0:se(ise):limlim;
        llim(ise) = length(lim);
    end
    se = se(find(llim<7,1,'first'));
    lim = 0:se:limlim;
    ax1.YAxis(2).TickValues = lim*pop/1e5;
    ax1.YAxis(2).TickLabels = lim;
    ax1.YColor = [0 0 0];
    
    l = legend('Number of cases','Prediction');
    
    h = [0 .25 .37]; h = [h 1-sum(h)]; h = cumsum(h);
    ax3 = axes('Units','normalized','Position',[ax1.Position(1)+0.01 ax1.Position(2)+ax1.Position(4)-.22  0.5 0.3]);
    plot([0 1],0.65*[1 1],'-k','linewidth',1.2)
    hold on
    plot([0 1],0.5*[1 1],'-k','linewidth',1.2)
    plot([0 1],0.38*[1 1],'-k','linewidth',.6)
    plot([0 1],0.26*[1 1],'-k','linewidth',.6)
    plot([0 1],0.14*[1 1],'-k','linewidth',1.2)
    plot(h(1)*[1 1] ,[.14 .65],'-k','linewidth',1.2)
    plot(h(2)*[1 1],[.14 .65],'-k','linewidth',1.2)
    plot(h(3)*[1 1],[.14 .65],'-k','linewidth',1.2)
    plot(h(4)*[1 1] ,[.14 .65],'-k','linewidth',1.2)
    text(0.5,.68,'Predictions for next days','HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',9,'FontWeight','bold')
    text(0.5*(h(1)+h(2)),.575,'Day','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',7,'FontWeight','bold')
    text(0.5*(h(2)+h(3)),.575,{'Number of cases'},'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',7,'FontWeight','bold')
    text(0.5*(h(3)+h(4)),.575,'Interval','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',7,'FontWeight','bold')
    text(0.5*(h(1)+h(2)),.4405,datestr(A(end)+1,'dd-mm-yyyy'),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
    text(0.5*(h(2)+h(3)),.4405,[ num2str(round(yp(1))) ' (+' num2str(round(yp(1)-y(end))) ')'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
    text(0.5*(h(3)+h(4)),.4405,['[ ' num2str(round(yp(1)-ep(1,1))) ' - ' num2str(round(yp(1)+ep(1,2))) ' ]'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
    if length(yp)>1
        text(0.5*(h(1)+h(2)),.325,datestr(A(end)+2,'dd-mm-yyyy'),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
        text(0.5*(h(3)+h(2)),.325,[ num2str(round(yp(2))) ' (+' num2str(round(yp(2)-yp(1))) ')'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
        text(0.5*(h(3)+h(4)),.325,['[ ' num2str(round(yp(2)-ep(2,1))) ' - ' num2str(round(yp(2)+ep(2,2))) ' ]'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
    end
    if length(yp)>2
        text(0.5*(h(1)+h(2)),.205,datestr(A(end)+3,'dd-mm-yyyy'),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
        text(0.5*(h(3)+h(2)),.205,[ num2str(round(yp(3))) ' (+' num2str(round(yp(3)-yp(2))) ')'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
        text(0.5*(h(4)+h(3)),.205,['[ ' num2str(round(yp(3)-ep(3,1))) ' - ' num2str(round(yp(3)+ep(3,2))) ' ]'],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',9)
    end
    axis([0 1 .08 1.08])
    ax3.XColor='none';
    ax3.YColor='none';
    %text(ax3,.05,0,['Actual measured incidence: ' num2str(y(end)/pop*1e5,'%3.2f')],'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',12)
    
    set(l,'Position',[ax1.Position(1)+0.02 .585 .3179 .1107])
    
    f2 = figure(2);
    clf
    if isempty(estimated)
        text((10+length(A)+Npred+1)/2,.5,'Not enough data','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'FontWeight','bold')
        ax1 = gca;
        ax1.TickDir = 'out';
        ax1.Box = 'off';
        ax1.LineWidth=2;
        ylabel('Number of cases')
        ax1.FontSize = 14;
        ax1.XLim=[10 length(A)+Npred+1];
        XT = sort(length(A):-7:0);
        ax1.XTick = XT;
        ax1.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
        xtickangle(45)
        ax1.XMinorTick='on';
        ax1.TickLength= [0.02 0.04];
        ax1.XColor = [0 0 0];
        ax1.YColor = [0 0 0];
    else
        yyaxis left
        plot(x,y,'o','MarkerFaceColor',[18 10 143]/255,'MarkerSize',3,'Color',[18 10 143]/255)
        hold on
        plot(x(1:length(estimated))-18,estimated,'o','MarkerFaceColor',[18 143 10]/255,'MarkerSize',3,'Color',[18 143 10]/255)
        ax1 = gca;
        ax1.TickDir = 'out';
        ax1.Box = 'off';
        ax1.LineWidth=2;
        ylabel('Number of cases')
        ax1.FontSize = 14;
        ax1.XLim=[T0 length(A)+Npred+1];
        XT = sort(length(A):-7:0);
        ax1.XTick = XT;
        ax1.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
        xtickangle(45)
        ax1.XMinorTick='on';
        ax1.TickLength= [0.02 0.04];
        ax1.XColor = [0 0 0];
        ax1.YColor = [0 0 0];
        Lim = ax1.YLim;
        yt = ax1.YTick;
        ax1.YTick = yt;
        ax1.YTickLabel = yt;
        
        yyaxis right
        plot(-1,-1,'ok')
        legend('confirmed cases','estimated cases')
        ax2 = gca;
        ax2.TickDir = 'out';
        ax2.Box = 'off';
        ax2.LineWidth=2;
        xlabel('Time (day)')
        ylabel('Cases per 10^5 inhabitants')
        ax2.FontSize = 14;
        ax2.XLim=[T0 length(A)+Npred+1];
        ax2.XTick = XT;
        ax2.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
        xtickangle(45)
        ax2.XMinorTick='on';
        ax2.TickLength= [0.02 0.04];
        ax2.XColor = [0 0 0];
        ax2.YColor = [0 0 0];
        ax2.YLim = Lim;
        limlim = Lim(2)/pop*1e5;
        se = [.1 .2 .5 1 2 5 10 20 50 100 200 500 1e3 2e3 5e3 1e4 2e4];
        llim = zeros(1,17);
        for ise = 1:17
            lim = 0:se(ise):limlim;
            llim(ise) = length(lim);
        end
        se = se(find(llim<7,1,'first'));
        lim = 0:se:limlim;
        ax2.YTick = lim*pop/1e5;
        ax2.YTickLabel = lim;
    end
    
    f3 = figure(3);
    clf
    if Nvect>0
        errorbar(tvect,avect(:,1),avect(:,2),avect(:,3),'.','linewidth',1,'Color',[48 40 143]/255)
        hold on
        plot(tvect,avect(:,1),'--','linewidth',1,'Color',[148 148 199]/255)
        plot(tvect,avect(:,1),'.','MarkerSize',12,'Color',[0 0 100]/255)
    else
        text((T0+length(A)+Npred+1)/2,.1,'Not enough data','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'FontWeight','bold')
    end
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (day)')
    ylabel('a (day^-^1)')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    ax.YLim = [0 0.2];
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    yt = ax.YTick;
    ax.YTick = yt;
    ax.YTickLabel = yt;
    
    
    f4 = figure(4);
    clf
    if Nvect>0
        errorbar(tvect,Kvect(:,1),Kvect(:,2),Kvect(:,3),'.','linewidth',1,'Color',[48 40 143]/255)
        hold on
        plot(tvect,Kvect(:,1),'--','linewidth',1,'Color',[148 148 199]/255)
        plot(tvect,Kvect(:,1),'.','MarkerSize',12,'Color',[0 0 100]/255)
    else
        text((T0+length(A)+Npred+1)/2,5e4,'Not enough data','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'FontWeight','bold')
    end
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (day)')
    ylabel('K (Final number of cases)')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    if pop>100e6
        ax.YLim = [1e4 1e7];
    else
        ax.YLim = [1e3 1e6];
    end
    ax.YScale ='log';
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    
    f5 = figure(5);
    clf
    yyaxis left
    bar(x(2:end),y(2:end)-y(1:end-1),'FaceColor',[90 80 203]/255)
    hold on
    bar(xp,np,'FaceColor',[220 20 60]/255)
    %errorbar(xp,np,en(:,1),en(:,2),'.','Color',[110 10 30]/255)
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (day)')
    ylabel('Incident observed cases')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    yt = ax.YTick;
    ax.YTick = yt;
    ax.YTickLabel = yt;
    Lim = ax.YLim;
    yyaxis right
    plot(-1,-1,'ok')
    %plot(x(2:end),y(2:end)-y(1:end-1),'o','MarkerSize',6,'MarkerFaceColor',[48 40 143]/255)
    ax2 = gca;
    ax2.TickDir = 'out';
    ax2.Box = 'off';
    ax2.LineWidth=2;
    xlabel('Time (day)')
    ylabel('Incident cases per 10^5 inhabitants')
    ax2.FontSize = 14;
    ax2.XLim=[T0 length(A)+Npred+1];
    ax2.XTick = XT;
    ax2.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax2.XMinorTick='on';
    ax2.TickLength= [0.02 0.04];
    ax2.XColor = [0 0 0];
    ax2.YColor = [0 0 0];
    ax2.YLim = Lim;
    limlim = Lim(2)/pop*1e5;
    se = [.1 .2 .5 1 2 5 10 20 50 100 200 500 1e3 2e3 5e3 1e4 2e4];
    llim = zeros(1,17);
    for ise = 1:17
        lim = 0:se(ise):limlim;
        llim(ise) = length(lim);
    end
    se = se(find(llim<7,1,'first'));
    lim = 0:se:limlim;
    ax2.YTick = lim*pop/1e5;
    ax2.YTickLabel = lim;
    legend('Confirmed','Prediction','location','northwest')
    
    f6 = figure(6);
    clf
    nw = y(2:end)-y(1:end-1);
    id = 7:(length(nw)-1);
    rh = (nw(id-1)+nw(id)+nw(id+1))./(nw(id-6)+nw(id-5)+nw(id-4));
    plot(x(id+1),rh,'o','MarkerSize',6,'MarkerFaceColor',[48 40 143]/255)
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (day)')
    ylabel('\rho')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    ax.YLim = [0 12];
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    yt = ax.YTick;
    ax.YTick = yt;
    ax.YTickLabel = yt;
    title(['Actual \rho = ' num2str(rh(end),'%2.1f')])
    
    f7 = figure(7);
    clf
    plot(x,z,'o','MarkerSize',6,'MarkerFaceColor',[48 40 143]/255)
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (days)')
    ylabel('Cumulative observed deaths')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    ax.YLim(1) = 0;
    ax.YLim(2) = max(5,ax.YLim(2));
    yt = ax.YTick;
    ax.YTick = yt;
    ax.YTickLabel = yt;
    Lim = ax.YLim;
    yyaxis right
    plot(-1,-1,'ok')
    ax2 = gca;
    ax2.TickDir = 'out';
    ax2.Box = 'off';
    ax2.LineWidth=2;
    xlabel('Time (day)')
    ylabel('Cumulative deaths per 10^5 inhabitants')
    ax2.FontSize = 14;
    ax2.XLim=[T0 length(A)+Npred+1];
    ax2.XTick = XT;
    ax2.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax2.XMinorTick='on';
    ax2.TickLength= [0.02 0.04];
    ax2.XColor = [0 0 0];
    ax2.YColor = [0 0 0];
    ax2.YLim = Lim;
    limlim = Lim(2)/pop*1e5;
    se = [.01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100 200 500 1e3 2e3 5e3 1e4 2e4];
    llim = zeros(1,length(se));
    for ise = 1:length(se)
        lim = 0:se(ise):limlim;
        llim(ise) = length(lim);
    end
    se = se(find(llim<7,1,'first'));
    lim = 0:se:limlim;
    ax2.YTick = lim*pop/1e5;
    ax2.YTickLabel = lim;
    
    f8 = figure(8);
    clf
    plot(x,100*z./y,'o','MarkerSize',6,'MarkerFaceColor',[48 40 143]/255)
    ax = gca;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.LineWidth=2;
    xlabel('Time (days)')
    ylabel('Case fatality rate (%)')
    ax.FontSize = 14;
    ax.XLim=[T0 length(A)+Npred+1];
    XT = sort(length(A):-7:0);
    ax.XTick = XT;
    ax.XTickLabel = datestr(XT+A(1)-1,'dd-mm');
    xtickangle(45)
    ax.XMinorTick='on';
    ax.TickLength= [0.02 0.04];
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];
    ax.YLim(1) = 0;
    yt = ax.YTick;
    ax.YTick = yt;
    ax.YTickLabel = yt;
    
    if guardar
        
        for i = 1:8
            print(eval(['f' num2str(i)]),['./figures/FIGURE' num2str(i)],'-dpng','-r600')
        end
        
        F1 = imread('./figures/FIGURE1.png');
        F2 = imread('./figures/FIGURE2.png');
        F3 = imread('./figures/FIGURE3.png');
        F4 = imread('./figures/FIGURE4.png');
        F5 = imread('./figures/FIGURE5.png');
        F6 = imread('./figures/FIGURE6.png');
        F7 = imread('./figures/FIGURE7.png');
        F8 = imread('./figures/FIGURE8.png');
        
        h=figure;
        set(h,'Units','centimeters');
        set(h,'Position',[0 0 21 29.7])
        set(h,'PaperPositionMode','Auto')
        set(h,'PaperSize',[21 29.7])
        
        HY = 0.02;
        hy = 0;
        hx = 0;
        
        LY = (1-HY-hy)/4;
        LX = 0.5-hx;
        
        axes('Units','normalized','Position',[hx hy LX LY])
        imagesc(F7)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx+LX hy LX LY])
        imagesc(F8)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx hy+LY LX LY])
        imagesc(F5)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx+LX hy+LY LX LY])
        imagesc(F6)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx hy+LY*2 LX LY])
        imagesc(F3)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx+LX hy+LY*2 LX LY])
        imagesc(F4)
        axis equal
        axis off
        axes('Units','normalized','Position',[hx hy+LY*3 LX LY])
        imagesc(F1)
        axis equal
        axis off
        nom = name;
        nom(nom=='_') = ' ';
        text(0,-200,[nom '  ' datestr(A(end),'dd-mm-yyyy') '. Population: ' num2str(pop/1e6,'%3.1f') 'M. Current cumulated incidence: ' num2str(round(y(end)/pop*1e5),'%u') '/10^5'],'FontSize',12,'HorizontalAlignment','left','FontWeight','bold')
        axes('Units','normalized','Position',[hx+LX hy+LY*3 LX LY])
        imagesc(F2)
        axis equal
        axis off
        
        print(h,[yF '/' num2str(y(end),'%06u') '-' name], '-fillpage','-dpdf','-r0')
        
    end
    
    xp = A(end) + (1:length(xp));
    
else
    xp=[];
    yp=[];
    ep=[];
end

end
function [y] = filtre_MC(x)

f = [1 3 5 3 1];
f = f/sum(f);

N = length(f);
n = (N-1)/2;

y = 0.*x;

for i = (n+1):(length(x)-n)
    y(i) = f*x((i-n):(i+n));
end

y(end-1) = f(1:4)/sum(f(1:4))*x(end-3:end);
y(end) = f(1:3)/sum(f(1:3))*x(end-2:end);

end