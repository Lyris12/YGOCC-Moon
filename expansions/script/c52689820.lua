--Ambidextrous Drivers
--Drivers Cacciavitambidestre
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,s.lcheck)
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetCondition(s.lkcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--[[If this card is Link Summoned: You can discard 1 card; choose 1 of these effects for each Drive Monster that was used as material for the Link Summon of this card,
	and resolve them in sequence (you cannot choose the same effect twice, and you resolve them in the listed order, skipping any that were not chosen);
	● Add 1 Level 2 or lower Drive Monster from your Deck to your hand.
	● Special Summon up to 2 of your Level 2 or lower Drive Monsters that are banished, in your hand, and/or in your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetLabel(0)
	e1:SetCondition(aux.LinkSummonedCond)
	e1:SetCost(s.hspcost)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--Check Materials
	local Mt=Effect.CreateEffect(c)
	Mt:SetType(EFFECT_TYPE_SINGLE)
	Mt:SetCode(EFFECT_MATERIAL_CHECK)
	Mt:SetValue(s.valcheck)
	Mt:SetLabelObject(e1)
	c:RegisterEffect(Mt)
	--[[If this card would be used as Synchro Material, your Engaged monster can be used as 1 of the other materials.
	If you do this, you can treat this card as a monster with a Level equal to the current Energy of that Engaged monster, when used for that Synchro Summon.]]
	aux.SynchroMaterialCustomForNonTuner(c,s.customsynmat,LOCATION_HAND,0,s.syntg,s.syntg_alt,s.synop,s.synop_alt)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetTargetRange(0,1)
	e3:SetTarget(s.handsynchro)
	c:RegisterEffect(e3)
	local synkoishi=Effect.CreateEffect(c)
	synkoishi:SetType(EFFECT_TYPE_SINGLE)
	synkoishi:SetCode(EFFECT_ALLOW_SYNCHRO_KOISHI)
	synkoishi:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	synkoishi:SetRange(LOCATION_MZONE)
	synkoishi:SetCondition(s.synconlv)
	synkoishi:SetValue(s.synclv)
	c:RegisterEffect(synkoishi)
	--[[You can decrease the Energy of your Engaged monster by up to 2; this card is treated as a Tuner, until the end of the turn.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(7)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetCost(aux.UpdateEnergyCost(-1,-2))
	e4:SetOperation(s.tnop)
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_DRIVE)
end

function s.synconlv(e)
	local ec=Duel.GetEngagedCard(e:GetHandlerPlayer())
	return ec~=nil and e:GetHandler():IsType(TYPE_TUNER)
end
function s.synclv(e,syncard)
	local lv=aux.GetCappedLevel(e:GetHandler())
	local ec=Duel.GetEngagedCard(e:GetHandlerPlayer())
	return ec:GetEnergy()
end

function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end

function s.valcheck(e,c)
	local ct=c:GetMaterial():FilterCount(Card.IsLinkType,nil,TYPE_DRIVE)
	local desc=1
	if ct==1 then
		desc=2
	else
		desc=3
	end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_TOFIELD,EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_IGNORE_IMMUNE,1,ct,aux.Stringid(id,desc))
end

function s.dcfilter(c,e,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,c,e,tp)
end
function s.thfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsLevelBelow(2) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsLevelBelow(2) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:HasFlagEffect(id) then
			e:SetLabel(0)
			return false
		end
		local spcheck = e:GetLabel()==1 or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		e:SetLabel(0)
		local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local b2 = Duel.GetMZoneCount(tp)>0 and spcheck
		return b1 or b2
	end
	e:SetLabel(0)
	local ct=c:GetFlagEffectLabel(id)
	Duel.SetTargetParam(ct)
	if ct>=2 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct then return end
	local opt
	if ct>=2 then
		opt=0x1|0x2
	else
		local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local b2 = Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		opt = 1<<aux.Option(tp,id,5,b1,b2)
	end
	if not opt then return end
	local breakeffect=false
	if opt&0x1>0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local _,hct=Duel.Search(g,tp)
			if hct>0 then
				breakeffect=true
			end
		end			
	end
	if opt&0x2>0 then
		local ft=Duel.GetMZoneCount(tp)
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,math.min(2,ft),nil,e,tp)
		if #g>0 then
			if breakeffect then
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
			end
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.customsynmat(e,c)
	return c==Duel.GetEngagedCard(e:GetHandlerPlayer())
end
function s.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function s.syncheck(c,handler,engaged,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=s.syngoal(handler,engaged,g,tp,lv,syncard,minc,ct) or (ct<maxc and mg:IsExists(s.syncheck,1,g,handler,engaged,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
function s.syngoal(handler,engaged,g,tp,lv,syncard,minc,ct)
	local res = (ct>=minc and (g:IsContains(engaged) or not g:IsContains(handler)) and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0 and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL))
	--Debug.Message('Synchro Level: '..tostring(handler:GetSynchroLevel(syncard))..' '..tostring(res))
	return res
end
function s.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	local ec=Duel.GetEngagedCard(tp)
	if lv<=c:GetSynchroLevel(syncard) then return false end
	local g=Group.FromCards(c)
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	local exg=Group.FromCards(ec):Filter(s.synfilter,c,syncard,c,f)
	mg:Merge(exg)
	local res=mg:IsExists(s.syncheck,1,g,c,ec,g,mg,tp,lv,syncard,minc,maxc)
	return res
end
function s.syntg_alt(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetLabelObject()
	
	local synkoishi=Effect.CreateEffect(c)
	synkoishi:SetType(EFFECT_TYPE_SINGLE)
	synkoishi:SetCode(EFFECT_ALLOW_SYNCHRO_KOISHI)
	synkoishi:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	synkoishi:SetRange(LOCATION_MZONE)
	synkoishi:SetValue(s.synclv)
	c:RegisterEffect(synkoishi)
	
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	local ec=e:GetHandler()
	if lv<=c:GetSynchroLevel(syncard) then synkoishi:Reset() return false end
	local g=Group.FromCards(c,ec)
	local res=s.syngoal(c,ec,g,tp,lv,syncard,minc,#g)
	if not res then
		local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,g,syncard,ec,f)
		local exg=Group.FromCards(ec):Filter(s.synfilter,g,syncard,ec,f)
		mg:Merge(exg)
		res = mg:IsExists(s.syncheck,1,g,c,ec,g,mg,tp,lv,syncard,minc,maxc)
	end
	synkoishi:Reset()
	return res
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	
	local lv=syncard:GetLevel()
	local ec=Duel.GetEngagedCard(tp)
	local g=Group.FromCards(c)
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	local exg=Group.FromCards(ec):Filter(s.synfilter,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(s.syncheck,g,c,ec,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if s.syngoal(c,ec,g,tp,lv,syncard,minc,i) then
			minct=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	Duel.SetSynchroMaterial(g)
end
function s.synop_alt(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetLabelObject()
	
	local synkoishi=Effect.CreateEffect(c)
	synkoishi:SetType(EFFECT_TYPE_SINGLE)
	synkoishi:SetCode(EFFECT_ALLOW_SYNCHRO_KOISHI)
	synkoishi:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	synkoishi:SetRange(LOCATION_MZONE)
	synkoishi:SetValue(s.synclv)
	c:RegisterEffect(synkoishi)
	
	local lv=syncard:GetLevel()
	local ec=e:GetHandler()
	local g=Group.FromCards(c,ec)
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,g,syncard,ec,f)
	local exg=Group.FromCards(ec):Filter(s.synfilter,g,syncard,ec,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(s.syncheck,g,c,ec,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if s.syngoal(c,ec,g,tp,lv,syncard,minc,i) then
			minct=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	synkoishi:Reset()
	Duel.SetSynchroMaterial(g)
end
function s.handsynchro(e,c,syncard)
	return c==Duel.GetEngagedCard(e:GetHandlerPlayer())
end

function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_TREATED_AS_TUNER)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
	