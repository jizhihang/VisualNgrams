function displayExamplesPerSubcat5_tmp2(objname, outdir, VOCyear, traindatatype)
% displayExamplesPerSubcat5_tmp1 but reruns 1x3 stuff at high res, equal
% sized; does 1x3 with avg+regular imgs; saves individual imgs

try    
disp(['displayExamplesPerSubcat5_tmp2(''' objname ''',''' outdir ''',''' VOCyear ''',''' traindatatype ''')' ]);

dispdir = [outdir '/display/']; mymkdir(dispdir);
  
disp('loading groundtruth info');
load([outdir '/' objname '_' traindatatype '_' VOCyear '.mat'], 'pos');
load([outdir '/' objname '_conf.mat'], 'conf');
load([outdir '/' objname '_mix.mat'], 'model'); 
numComps = numel(model.rules{model.start});
clear model;

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

disp('get the 1x3 image');
mimg_googprev = getGoogPrevMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], numComps, model_mix);
%mimg_googprevNavg = getGoogPrevMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
%    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], numComps, model_mix);
for k=1:numComps+1
    imwrite(mimg_googprev{k}, [dispdir '/montageGoogPrev2_' num2str(k-1, '%02d') '.jpg']);
    %imwrite(mimg_googprevNavg{k}, [dispdir '/montageGoogAVGPrev_' num2str(k-1, '%02d') '.jpg']);
end
myprintfn;
  
catch
    disp(lasterr); keyboard;
end
