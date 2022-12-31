--created & coded by Lyris
--襲雷降雨
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetCondition(function() local ph=Duel.GetCurrentPhase() return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x7c4) and c:IsCanBeEffectTarget(e)
end
function s.filter(c,e,tp,lsc,rsc)
	local lv=c:GetLevel()
	return c:IsSetCard(0x7c4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsFaceup()
		or not c:IsLocation(LOCATION_EXTRA)) and lsc>lv and lv>rsc
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_PZONE,0,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCurrentScale)>1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,g:GetFirst():GetCurrentScale(),g:GetNext():GetCurrentScale()) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.chk(g)
	return g:GetClassCount(Card.GetLocation)==#g
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.Destroy(g,REASON_EFFECT)<1 or ft<1 then return end
	local t={}
	for tc in aux.Next(Duel.GetOperatedGroup()) do
		local l,r=tc:GetLeftScale(),tc:GetRightScale()
		if not t[l] then t[l]=1 else t[l]=t[l]+1
		if not t[r] then t[r]=1 else t[r]=t[r]+1
	end
	if #t<2 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp,t)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(mg:SelectSubGroup(tp,s.chk,false,1,math.min(ft,3)),0,tp,tp,false,false,POS_FACEUP)
end
