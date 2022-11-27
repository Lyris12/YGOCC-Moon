--Heterochromic Neo Tuner
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000437.initial_effect(c)
	if aux.AddSynchroProcedure then
		if not c249000437_AddSynchroProcedure then
			c249000437_AddSynchroProcedure=aux.AddSynchroProcedure
			aux.AddSynchroProcedure = function (c,f1,f2,minc,maxc)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				if f1 then
					mt.c249000437_tuner_filter=function(mc) return mc and f1(mc) end
				else
					mt.c249000437_tuner_filter=function(mc) return true end
				end
				if f2 then
					mt.c249000437_nontuner_filter=function(mc,c) return mc and f2(mc,c) end
				else
					mt.c249000437_nontuner_filter=function(mc,c) return true end
				end
				mt.minntct=minc
				if maxc==nil then mt.maxntct=99 else mt.maxntct=maxc end
				mt.sync=true
				c249000437_AddSynchroProcedure(c,f1,f2,minc,maxc)
			end
		end
	end
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89326990,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,249000437)
	e1:SetCost(c249000437.cost)
	e1:SetTarget(c249000437.target)
	e1:SetOperation(c249000437.operation)
	c:RegisterEffect(e1)
	--synchro limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
end
function c249000437.costfilter(c)
	return c:IsSetCard(0x1BE) and c:IsDiscardable() and not c:IsCode(249000437)
end
function c249000437.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000437.costfilter,tp,LOCATION_HAND,0,1,nil) end
	if Duel.GetLP(tp) < 4000 then
		Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	else
		Duel.PayLPCost(tp,2000)
	end
	Duel.DiscardHand(tp,c249000437.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c249000437.matfilter(c,lv,syncard,mclv)
	local code=syncard:GetOriginalCode()
	local mt=_G["c" .. code]
	return c:IsLevelAbove(5) and c:GetSynchroLevel(syncard)==lv-mclv and c:IsNotTuner(syncard) and c:IsAbleToRemove() 
		and mt.c249000437_nontuner_filter and mt.c249000437_nontuner_filter(c,syncard)
end
function c249000437.filter(c,e,tp,mc)
	local code=c:GetOriginalCode()
	if banned_list_table[code] then return false end
	local mt=_G["c" .. code]
	local mclv=mc:GetSynchroLevel(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,true,false)
		and Duel.IsExistingMatchingCard(c249000437.matfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLevel(),c,mclv) 
		and mt.sync and mt.minntct and mt.minntct==1 and mt.c249000437_tuner_filter and mt.c249000437_tuner_filter(mc)
end
function c249000437.tgfilter(c)
	return c:IsAbleToRemove() and not c:IsType(TYPE_TUNER) and c:IsLevelAbove(5)
end
function c249000437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsAbleToRemove() 
		and Duel.IsExistingMatchingCard(c249000437.tgfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249000437.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ac=Duel.AnnounceCardFilter(tp,TYPE_SYNCHRO,OPCODE_ISTYPE,249000437,OPCODE_ISCODE,OPCODE_OR)
	local tc=Duel.CreateToken(tp,ac)
	if tc:IsCode(249000437) then return end
	while not c249000437.filter(tc,e,tp,c)
	do
		ac=Duel.AnnounceCardFilter(tp,TYPE_SYNCHRO,OPCODE_ISTYPE,249000437,OPCODE_ISCODE,OPCODE_OR)
		tc=Duel.CreateToken(tp,ac)
		if tc:IsCode(249000437) then return end
	end
	local code=tc:GetOriginalCode()
	local mt=_G["c" .. code]
	local mclv=c:GetSynchroLevel(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local mat=Duel.SelectMatchingCard(tp,c249000437.matfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc:GetLevel(),tc,mclv)
	mat:AddCard(c)
	tc:SetMaterial(mat)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
	Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,true,false,POS_FACEUP)
	tc:CompleteProcedure()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	tc:RegisterEffect(e2,true)
end
