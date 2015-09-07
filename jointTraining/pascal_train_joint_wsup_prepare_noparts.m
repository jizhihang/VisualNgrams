function pascal_train_joint_wsup_prepare_noparts(cls, objname, phrasenames, cachedir, year, fg_olap, borderoffset, jointCacheLimit, n_perngram, do_retraining)

try
% At every "checkpoint" in the training process the 
% RNG's seed is reset to a fixed value so that experimental results are 
% reproducible.
seed_rand();

if isdeployed, n_perngram = str2num(n_perngram); end
if isdeployed, fg_olap = str2num(fg_olap); end
if isdeployed, borderoffset = str2num(borderoffset); end
if isdeployed, jointCacheLimit = str2num(jointCacheLimit); end  %set this variable corectly/calclate; be careful while modifying params (rembr ur old exp where u modified memory and had to modify #iterations)
if isdeployed, do_retraining = str2num(do_retraining); end

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
VOC_CONFIG_OVERRIDE.training.fg_overlap = fg_olap; %0.25;
VOC_CONFIG_OVERRIDE.training.train_set_fg = 'train';
diary([cachedir '/diaryoutput_train.txt']);
disp(['pascal_train_joint_wsup_prepare_noparts(''' cls ''',''' objname ''','' phrasenames '',''' cachedir ''',''' year ''',' num2str(fg_olap) ',' num2str(borderoffset) ',' num2str(jointCacheLimit) ',' num2str(n_perngram) ',' num2str(do_retraining) ')' ]);

% set this variable corectly/calclate; be careful while modifying params
% (rembr ur old exp where u modified memory and had to modify #iterations)
VOC_CONFIG_OVERRIDE.training.cache_byte_limit = jointCacheLimit; %2*(3*2^30);
conf = voc_config();
disp(['RAM usage is ' num2str(conf.training.cache_byte_limit)]); 
conf.borderoffset = borderoffset;

mymkdir([cachedir '/intermediateModels/']); 

filenameWithPath = which('linuxUpdateSystemNumThreadsToMax.sh');    % avoids hardcoding filepath (/projects/grail/santosh/objectNgrams/code/utilScripts/linuxUpdateSystemNumThreadsToMax.sh')
system(['. ' filenameWithPath]);                                    % the dot is important
%linuxUpdateSystemNumThreadsToMax_mat;

max_num_examples = conf.training.cache_example_limit;
num_fp           = conf.training.wlssvm_M;
fg_overlap       = conf.training.fg_overlap;

try
    load([cachedir cls '_joint_data_noparts'], 'pos', 'impos', 'neg', 'models_all', 'model', ...
        'inds_befjnt', 'posscores_befjnt', 'lbbox_befjnt');
catch
    disp('Load existing data (pos, neg, models)');
    k = 1;
    listOfSelNgramComps_globalIds = [];
    listOfSelNgramComps_accs = [];
    [pos_all, impos_all, models_all, inds_befjnt, posscores_befjnt, lbbox_befjnt] = deal([]);
    for ii = 1:numel(phrasenames)
        myprintf(ii,10);
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_' conf.training.train_set_fg '_' conf.pascal.year], 'pos', 'neg', 'impos');
        [pos, neg, impos] = updatePathForAWS(pos, neg, impos);
        
        %%% loading _mix 'model' instead of parts
        %load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_parts'], 'models', 'docomps');        
        %%% converting 'model' to 'models'
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_lrsplit1'], 'models');        
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix'], 'model');   %models = model_split(model, models);        
        for pp = 1:n_perngram
            % bias
            bl_lhs = models{pp}.rules{models{pp}.start}(1).offset.blocklabel;
            bl_rhs = model.rules{model.start}(pp).offset.blocklabel;
            if numel(models{pp}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
            models{pp}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
            
            % filter (dsk: not sure how to index into filter, for now "-1" is a hack)
            bl_lhs = models{pp}.rules{models{pp}.start}(1).offset.blocklabel-1;
            bl_rhs = model.rules{model.start}(pp).offset.blocklabel-1;
            if numel(models{pp}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
            models{pp}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
        end
                
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix'], 'inds_mix', 'posscores_mix', 'lbbox_mix');        
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix_goodInfo2'], 'selcomps', 'selcompsInfo');
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix_goodInfo'], 'roc');
        [compaps_full, compaps] = deal(zeros(n_perngram,1));
        for ck=1:n_perngram
            compaps_full(ck) = roc{ck}.ap_full_new*100;
            compaps(ck) = roc{ck}.ap_new*100;
        end
        for j=1:n_perngram
            if selcomps(j) == 1
                %if docomps(j) ~= 1, disp('this model not trained'); keyboard; end
                models_all{k} = models{j};
                models_all{k}.class = [models{j}.class ' ' num2str(j)];
                listOfSelNgramComps_globalIds = [listOfSelNgramComps_globalIds; (ii-1)*n_perngram+j];
                listOfSelNgramComps_accs = [listOfSelNgramComps_accs; compaps_full(j)];
                pos_tmp = pos(inds_mix == j);
                impos_tmp = impos(inds_mix == j);
                for jj=1:numel(pos_tmp)     % add comp info to impos
                    pos_tmp(jj).thisPosModelId = k;
                    impos_tmp(jj).thisPosModelId = k;
                end
                inds_befjnt = [inds_befjnt; k*ones(numel(pos_tmp),1)];
                posscores_befjnt = [posscores_befjnt; posscores_mix(inds_mix==j,:)];
                lbbox_befjnt = [lbbox_befjnt; lbbox_mix(inds_mix==j,:)];
                if ~isempty(pos_tmp), pos_all = [pos_all pos_tmp]; end
                if ~isempty(impos_tmp), impos_all = [impos_all impos_tmp]; end
                k = k + 1;
            end
        end
    end
    myprintfn;
          
    pos = pos_all;
    impos = impos_all;    
                
    disp('get negatives'); 
    %neg = neg;      % neg of last guy  ('train' set)
    neg = pascal_data_wsup_neg(conf.pascal.VOCopts, ['baseobjectcategory_' objname '_val1_withLabels'], year);  %'val' set
    [pos, impos, neg] = updateDataIds_jointData(pos, impos, neg);   
    model = [];
    if ~isempty(models_all), model = model_merge(models_all); end
    [model.phrasenames, model.compSize] = getphraseInfo_modelmerged(models_all, [cachedir '/componentNamesWithIndices.txt']);
    model.class = cls;
    
    disp(' include image urls, their size, and final bbox score+coords (for releasing images)');    
    [poscell, posdata] = getSortedPosDataPerCompWithURLs(pos, posscores_befjnt, lbbox_befjnt, model);
    
    clear pos_all impos_all;
    save([cachedir cls '_joint_data_noparts.mat'], 'pos', 'impos', 'neg', 'models_all', 'model',...
        'inds_befjnt', 'posscores_befjnt', 'lbbox_befjnt', 'listOfSelNgramComps_globalIds',...
        'listOfSelNgramComps_accs');   
    save([cachedir cls '_joint_noparts'], 'model');
    save([cachedir cls '_joint_noparts'], 'posdata', 'poscell', '-append');    
end 
myprintfn;

disp(['got a total of ' num2str(numel(model.rules{model.start})) ' components']);

diary off;

catch
    disp(lasterr); keyboard;
end
