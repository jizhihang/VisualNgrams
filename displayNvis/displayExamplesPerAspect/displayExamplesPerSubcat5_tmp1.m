function displayExamplesPerSubcat5_tmp1(objname, outdir, VOCyear, traindatatype)
% displayExamplesPerSubcat5 but just the 3x3, 7x7 and 1x3 stuff for running just old
% classes

try    
disp(['displayExamplesPerSubcat5_tmp(''' objname ''',''' outdir ''',''' VOCyear ''',''' traindatatype ''')' ]);

dispdir = [outdir '/display/']; mymkdir(dispdir);
numToDisplay = 49;
  
disp('loading groundtruth info');
load([outdir '/' objname '_' traindatatype '_' VOCyear '.mat'], 'pos');
if exist('/home/ubuntu/JPEGImages/','dir')
    for i=1:numel(pos)
        [~, thisid] = myStrtokEnd(pos(i).im,'/');
        pos(i).im = ['/home/ubuntu/JPEGImages/' thisid];
    end    
end
load([outdir '/' objname '_conf.mat'], 'conf');
load([outdir '/' objname '_mix.mat'], 'model'); 
numComps = numel(model.rules{model.start});
clear model;

% INIT
disp('getting subcategory membership kmeans initialization');
try 
    load([outdir '/' objname '_displayInfo.mat'], 'inds_init'); 
catch    
    %posscores_init = zeros(length(pos), 1);
    %lbbox_init = zeros(length(pos), 4);
    %for i=1:length(pos)
    %    lbbox_init(i,:) = [pos(i).x1 pos(i).y1 pos(i).x2 pos(i).y2];
    %end
end

if ~exist([outdir '/' objname '_lrsplit2.mat'], 'file')
% LRSPLIT1
modeltype = 'lrsplit1';
disp(['loading modeltype ' modeltype]);    
fname = [outdir '/' objname '_' modeltype '.mat'];
try 
    load(fname, 'models', 'model', 'inds_lrsplit1', 'posscores_lrsplit1', 'lbbox_lrsplit1');
    inds_lrsplit1;
    if ~exist('model', 'var'), model = model_merge(models); end
    model_lr = model;
catch
    load(fname, 'models', 'model');
    if ~exist('model', 'var'), model = model_merge(models); end
    disp(' getting subcategory membership info');    
    [inds_lrsplit1, posscores_lrsplit1, lbbox_lrsplit1] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_lrsplit1', 'posscores_lrsplit1', 'lbbox_lrsplit1', '-append');
end
inds_lrs =  inds_lrsplit1; posscores_lrs = posscores_lrsplit1; lbbox_lrs = lbbox_lrsplit1;
else
% LRSPLIT2
modeltype = 'lrsplit2';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
try 
    load(fname, 'inds_lrs2', 'posscores_lrs2', 'lbbox_lrs2');
    inds_lrs2;
catch
    load(fname, 'model', 'models');
    if ~exist('model', 'var'), model = model_merge(models); end
    disp(' getting subcategory membership info');
    [inds_lrs2, posscores_lrs2, lbbox_lrs2] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_lrs2', 'posscores_lrs2', 'lbbox_lrs2', '-append');
end
inds_lrs =  inds_lrs2; posscores_lrs = posscores_lrs2; lbbox_lrs = lbbox_lrs2;
end

% MIX
modeltype = 'mix';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
try 
    load(fname, 'model', 'inds_mix', 'posscores_mix', 'lbbox_mix');
    inds_mix;
    model_mix = model;
catch
    load(fname, 'model');
    disp(' getting subcategory membership info');
    [inds_mix, posscores_mix, lbbox_mix] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_mix', 'posscores_mix', 'lbbox_mix', '-append');
end

% PARTS
modeltype = 'parts';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
if exist(fname,'file') && 0
    try
        load(fname, 'inds_parts', 'posscores_parts', 'lbbox_parts');
        inds_parts;
    catch
        load(fname, 'model');
        disp(' getting subcategory membership info');
        [inds_parts, posscores_parts, lbbox_parts] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
        save(fname, 'inds_parts', 'posscores_parts', 'lbbox_parts', '-append');
    end
else
    [inds_parts, posscores_parts, lbbox_parts] = deal([]);
end

disp('get the 3x3 & AVG image');
%[mimg_lrs3x3, ~, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds_lrs, inds_lrs, ...
%    inds_lrs, posscores_lrs, posscores_lrs, lbbox_lrs, pos, [], numComps, model_lr);
[mimg_lrs3x3, ~, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, 9, numComps, model_mix);
mimg_lrs7x7 = get3x3MontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, 49, numComps, model_mix);
mimg_googprev = getGoogPrevMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], numComps, model_mix);
for k=1:numComps+1
    imwrite(mimg_lrs3x3{k}, [dispdir '/montage3x3_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_avg{k}, [dispdir '/montageAVG_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_lrs7x7{k}, [dispdir '/montage7x7_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_googprev{k}, [dispdir '/montageGoogPrev_' num2str(k-1, '%02d') '.jpg']);
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
