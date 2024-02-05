--[[
Backdoor
Backdoor
Card Author: Burndown
Scripted by: XGlitchy30
]]


local s,id=GetID()
function s.initial_effect(c)
	--[[Banish 3 "Viravolve" monsters from your GY; Special Summon 1 "Viravolve" monster from your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VIRAVOLVE) and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_VIRAVOLVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gcheck(g,e,tp)
	return Duel.GetMZoneCount(tp,g)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,g,e,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return g:CheckSubGroup(s.gcheck,3,3,e,tp)
	end
	Duel.HintMessage(tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,e,tp)
	if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or (Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end