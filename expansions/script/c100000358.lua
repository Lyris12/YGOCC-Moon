--[[
Vacuous Exarch
Esarca Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_ZONE)
	--[[During your opponent's turn (Quick Effect): You can banish 1 "Vacuous Vassal" from your field or GY; Special Summon this card from your hand, and if you do, send 1 "Vacuous Vassal" and 1
	Trap that mentions "Power Vacuum Zone" from your hand or Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:HOPT()
	e1:SetFunctions(
		aux.MainPhaseCond(),
		aux.BanishCost(s.cfilter,LOCATION_ONFIELD|LOCATION_GRAVE,0,1),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[You can banish this card until the next Standby Phase; add 1 "Power Vacuum Zone" or 1 card that mentions it from your Deck or GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		s.thcost,
		xgl.SearchTarget(s.thfilter,LOCATION_DECK|LOCATION_GRAVE),
		xgl.SearchOperation(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	)
	c:RegisterEffect(e2)
	--[[While you control "Power Vacuum Zone", monsters your opponent controls are banished instead of being sent to the GY.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_FZONE,0,1))
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_VACUOUS_VASSAL) and Duel.GetMZoneCount(tp,c)>0
end
function s.tgfilter1(c,tp)
	return c:IsCode(CARD_VACUOUS_VASSAL) and c:IsAbleToGrave() and Duel.IsExists(false,s.tgfilter2,tp,LOCATION_HAND|LOCATION_DECK,0,1,c)
end
function s.tgfilter2(c)
	return c:IsTrap() and c:Mentions(CARD_POWER_VACUUM_ZONE) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExists(false,s.tgfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g1=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
		if #g1==0 then return end
		local g2=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter2,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,g1)
		if #g2==0 then return end
		g1:Merge(g2)
		Duel.SendtoGrave(g1,REASON_EFFECT)
	end
end

--E2
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	Duel.BanishUntil(c,e,tp,nil,PHASE_STANDBY,id,1,true,c,REASON_COST)
end
function s.thfilter(c)
	return c:IsCodeOrMentions(CARD_POWER_VACUUM_ZONE)
end