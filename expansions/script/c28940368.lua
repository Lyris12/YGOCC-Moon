--Converguard Apotheosis
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(ref.sscon)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	--Return
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.dktg)
	e2:SetOperation(ref.dkop)
	c:RegisterEffect(e2)
end

--Activate
function ref.sscon(e,tp)
	local ph=Duel.GetCurrentPhase()
	return bit.band(ph,PHASE_BATTLE_STEP|PHASE_BATTLE_START|PHASE_BATTLE)>0 or (Duel.GetTurnPlayer()==tp and bit.band(ph,PHASE_MAIN1|PHASE_MAIN2)>0)
end
function ref.ssfilter(c,e,tp)
	return Converguard.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function ref.thfilter(c,id) return Converguard.Is(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id) end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp)
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Destroy(tc,REASON_EFFECT)~=0
	and Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil,g:GetFirst():GetCode()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetCode())
		if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,hg) end
	end
end

--Return
function ref.dkfilter(c) return c:IsFaceup() and c:IsType(TYPE_TIMELEAP) and c:IsAbleToExtra() end
function ref.dktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ref.dkfilter(chkc) and (chkc:IsLocation(LOCATION_REMOVED) or (chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE))) end
	if chk==0 then return Duel.IsExistingTarget(ref.dkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.dkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,#g,0,0)
end
function ref.dkop(e,tp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then Duel.SendtoDeck(g,nil,2,REASON_EFFECT) end
end
