--Mover of Deptheaven and Earth
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	aux.AddXyzProcedure(c,Deptheaven.Is,4,2,nil,nil,99)
	c:EnableReviveLimit()
	--Global Xyz Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(ref.xyzlv)
	c:RegisterEffect(e1)
	--Fast Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end)
	e2:SetCost(ref.sscost)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
	--Shuffle Heal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(ref.rettg)
	e3:SetOperation(ref.retop)
	c:RegisterEffect(e3)
end

function ref.xyzlv(e,c,rc)
	if rc:GetOwner()==e:GetHandlerPlayer() and rc:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_LIGHT) and rc:IsRankBelow(10) then
		return c:GetLevel()+0x10000*rc:GetRank()
	else return c:GetLevel() end
end

--Fast Summon
function ref.ssfilter(c,e,tp) return Deptheaven.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
	if Duel.IsExistingMatchingCard(Card.IsSpecialSummonable,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xg=Duel.SelectMatchingCard(tp,Card.IsSpecialSummonable,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if #xg>0 then Duel.SpecialSummonRule(tp,xg:GetFirst()) end
	end
end

--Shuffle Heal
function ref.retfilter(c)
	return (Deptheaven.Is(c) or c:IsType(TYPE_XYZ)) and c:IsAbleToDeck()
end
function ref.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.retfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.retfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.retfilter,tp,LOCATION_GRAVE,0,1,99,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*500)
end
function ref.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
