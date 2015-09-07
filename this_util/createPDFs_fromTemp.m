function createPDFs_fromTemp

basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
allpdfsdir = ['/projects/grail/santosh/objectNgrams/results/pdfsdir/']; mymkdir(allpdfsdir);    
testdatatype = 'test';   
testyear = '2007';
numcomp = 6;   
myClasses = VOCoptsClasses; 
for i=1:numel(myClasses)
    objname = myClasses{i};
    disp(objname);
    ngramImgClfrdir_obj = [basedir '/' objname '/ngramPruning/'];
    
    supNgMatFname = [ngramImgClfrdir_obj '/' objname '_all_fastClusters.mat'];    
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_all_fastClusters_super.txt'];
        
    baseobjdir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
    pdfdir = [baseobjdir '/pdfdisplay/']; mymkdir(pdfdir);
    pdfDispOutFname = [pdfdir '/ngramSummary.tex'];
    pdfDispOutFname_pdf = [pdfdir '/ngramSummary.pdf'];
    disptestFname = [baseobjdir '/display_' testdatatype '_' testyear '_' testyear '/all_test_2007_joint_001-100.jpg'];                 
    if ~exist([allpdfsdir '/' objname '.pdf'], 'file')
        try
            dumpResultsToPDF(objname, pdfdir, pdfDispOutFname, supNgMatFname, fname_imgcl_sprNg, baseobjdir, disptestFname, numcomp);
            wwwdispdir_part = [objname '_trainNtestVis/'];
            wwwdispdir = ['/projects/grail/www/projects/visual_ngrams/display/' wwwdispdir_part];
            %wwwdispdir = ['/projects/www/projects/visual_ngrams/display/' wwwdispdir_part];
            %copyfile(pdfDispOutFname_pdf, [wwwdispdir '/selectedComponetsDisplay.pdf']);
            copyfile(pdfDispOutFname_pdf, [allpdfsdir '/' objname '.pdf']);
        end
    end
end
