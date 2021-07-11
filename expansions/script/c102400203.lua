--created & coded by Lyris
--ローマ・キー・XXXVI
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xeeb) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false)
end
function s.filter(c,e,tp,mg)
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL) or c:GetLevel()<=0
		or not c:IsSetCard(0xeeb) or not c:IsCanBeFusionMaterial() then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	return #sg>0 and mg:CheckSubGroup(function(tg) return sg:CheckSubGroup(function(g) return g:GetSum(Card.GetLevel)<=tg:GetSum(Card.GetLevel) end,1,ft) end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeFusionMaterial,Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,e:GetHandler())
		return mg:IsExists(s.filter,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeFusionMaterial,Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mat=mg:FilterSelect(tp,s.filter,1,99,nil,e,tp,mg)
	if #mat==0 then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,mat,e,tp)
	local ft=Duel.GetLocationCountFromEx(tp,tp,mat,TYPE_FUSION)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=sg:SelectSubGroup(tp,function(g) return g:GetSum(Card.GetLevel)<=mat:GetSum(Card.GetLevel) end,false,1,ft)
	for tc in aux.Next(tg) do tc:SetMaterial(mat) end
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	for nc in aux.Next(tg) do
		Duel.SpecialSummonStep(nc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
		nc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end
