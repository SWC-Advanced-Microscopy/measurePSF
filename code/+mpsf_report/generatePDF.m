function generatePDF(data_dir)
    % Makes all plots defined by the gen plot structure
    %
    % function generatePDF(data_dir)
    %
    % Purpose
    % Makes all available plots from a data directory and tiles them over the screen.
    % If no input is provided, it looks in the current directory for data.
    %
    % Inputs
    % data_dir - [optional] location of data directory.
    %
    % Outputs
    % none
    %
    % See also
    % mpsf_report.plotAllBasic
    %
    % Rob Campbell - SWC 2022


    % Bail out if the user lacks the report generator
    v = ver;
    if ~contains([v.Name] ,'MATLAB Report Generator')
        fprintf('\nThis function requires the MATLAB Report Generator to be installed\n')
        fprintf('If you can not install it, see mpsf_report.plotAllBasic\n\n')
        return
    end



    % Generate the structure we will use to make the plots
    if nargin<1
        data_dir = pwd;
    end

    GEN=mpsf_report.plot_functions_generator(data_dir);

    % Java imports
    import mlreportgen.dom.*;
    import mlreportgen.report.*;


    % Preferences
    rpt = Report('figureSnapshotSideBySideLandscape','pdf');
    rpt.Layout.Landscape = true;
    imgStyle = {ScaleToFit(true)};



    %% Intro to the report by summarising whatever information we can automatically generate
    chapter = Chapter('Title', 'Introduction');
    p1 = Paragraph(mpsf_report.generate_summary_text);


    add(chapter,p1)
    add(rpt,chapter)




    %% Electrical noise at each channel
    chapter = Chapter('Title', 'Electrical Noise At Each Channel');


    f=find(strcmp({GEN.type},'electrical_noise'));
    GEN(f).plotting_func(GEN(f).full_path_to_data)

    fig = Figure();

    figImg = Image(getSnapshotImage(fig, rpt));
    figImg.Style = imgStyle;

    add(chapter, fig)
    add(rpt,chapter)
    delete(gcf);





    %% Uniform slide image
    chapter = Chapter('Title', 'Image uniformity');

    f=find(strcmp({GEN.type},'uniform_slide'));
    GEN(f).plotting_func(GEN(f).full_path_to_data)

    fig = Figure();

    figImg = Image(getSnapshotImage(fig, rpt));
    figImg.Style = imgStyle;
    delete(gcf);

    add(chapter, figImg);
    add(rpt, chapter);



    %% Image stability with time
    chapter = Chapter('Title', 'Laser stability');

    f=find(strcmp({GEN.type},'laser_stability'));
    GEN(f).plotting_func(GEN(f).full_path_to_data)

    fig = Figure();

    figImg = Image(getSnapshotImage(fig, rpt));
    figImg.Style = imgStyle;
    delete(gcf);

    add(chapter, figImg);
    add(rpt, chapter);



    close(rpt);
    rptview(rpt);

