--[[
Curseflame Noble Rasa
Nobile Fiammaledetta Rasa
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	--You can also use 1 monster your opponent controls with 3 or more Curseflame Counters as material to Link Summon this card, but if you do, you cannot use this card as Link Material during that turn.
	aux.AllowExtraLinkMaterialOperation = true
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(0,LOCATION_MZONE)
	e0:SetValue(s.matval)
	e0:SetOperation(s.matop)
	c:RegisterEffect(e0)
	--If this card is Link Summoned: You can send 1 "Curseflame" card from your hand to the GY; Special Summon 1 "Curseflame" monster from your hand, Deck, or GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--(Quick Effect): You can Tribute this card; distribute 3 Curseflame Counters among face-up cards on the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.TributeSelfCost,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e2)
end
--E0
function s.matfilter(c)
	return c:IsLinkSetCard(ARCHE_CURSEFLAME) or s.exmatfilter(c,self_reference_effect:GetHandlerPlayer())
end
function s.exmatfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:GetCounter(COUNTER_CURSEFLAME)>=3
end
function s.exmatcheck(c,lc,tp)
	if not s.exmatfilter(c,tp) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do	 
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and not te:GetOwner():IsCode(id) then return false end
	end
	return true	  
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return c:GetCounter(COUNTER_CURSEFLAME)>=3, not mg or not mg:IsExists(s.exmatcheck,1,nil,lc,tp)
end
function s.matop(e,tp,lc,mg,mg_without_tc,tc)
	local e1=Effect.CreateEffect(lc)
	e1:SetDescription(STRING_CANNOT_BE_LINK_MATERIAL)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD|RESET_PHASE|PHASE_END)
	lc:RegisterEffect(e1)
end

--E1
function s.tgfilter(c,e,tp)
	if not (c:IsSetCard(ARCHE_CURSEFLAME) and c:IsAbleToGraveAsCost()) then return false end
	c:SetLocationAfterCost(LOCATION_GRAVE)
	local res = (c:IsOwner(tp) and s.spfilter(c,e,tp)) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,c,e,tp)
	c:SetLocationAfterCost(0)
	return res
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_CURSEFLAME) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=e:IsCostChecked() and e:GetHandler() or nil
		local cg=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
		return cg:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME),1,#cg,3)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,tp,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #cg>0 then
		Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,3,cg,id)
	end
end