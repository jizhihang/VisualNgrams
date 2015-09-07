function getSortedPosDataPerCompWithURLs_wrapper
%{
compileCode_v2_depfun('getSortedPosDataPerCompWithURLs_wrapper', 1);
resdir = '/projects/grail/santosh/objectNgrams/results/ngram_models/dump/SortedPosDataDone/';
multimachine_grail_compiled('getSortedPosDataPerCompWithURLs_wrapper', 150, resdir, 1, [], randqname, 8, 0, 1, 0);
%}

disp('Include image urls, their size, and final bbox coords (for releasing images)');

basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 

resdir = [basedir '/dump/SortedPosDataDone/']; mymkdir(resdir);
%for i=1:numel(myClasses)    
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(myClasses)); 
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
        
    disp(['Processing object ' num2str(f)]);

    objname = myClasses{f};
    disp(objname);

    ngramModeldir_obj = [basedir '/' objname '/' 'kmeans_6' '/']; 
    cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; 
    fname_load1 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_data_noparts.mat'];
    fname_save1 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_noparts.mat'];
    fname_load2 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_data.mat'];
    fname_save2 = [cachedir '/' ['baseobjectcategory_' objname] '_joint.mat'];
    if exist(fname_load2, 'file')
        disp('doing fname_load2');
        fname_load = fname_load2;
        fname_save = fname_save2;        
    elseif exist(fname_load1, 'file')
        disp('doing fname_load1');
        fname_load = fname_load1;
        fname_save = fname_save1;        
    end
    
    try
        clear posdata poscell;
        load(fname_save, 'posdata');
        posdata(end).imgurl;
        disp('already done');
    catch
        tmp = load(fname_load, 'pos', 'lbbox_befjnt', 'posscores_befjnt', 'model');
        lbbox_befjnt = tmp.lbbox_befjnt;
        posscores_befjnt = tmp.posscores_befjnt;
        pos = tmp.pos;
        model = tmp.model;
                  
        [poscell, posdata] = getSortedPosDataPerCompWithURLs(pos, posscores_befjnt, lbbox_befjnt, model);
                
        save(fname_save, 'posdata', 'poscell', '-append');
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);    
end
