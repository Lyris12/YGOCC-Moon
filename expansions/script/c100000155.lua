--[[
Crystarion Sage - Contractor of Cobalt
Saggio Cristarione - Appaltatore di Cobalto
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,13)
	--[[▼ [-9]: Special Summon 1 "Crystarion Ascendant - Pillar of Cobalt" from your hand or GY.
	While it is face-up on the field, "Crystarion" Ritual Monsters you control cannot be destroyed by your opponent's card effects.]]
	local d1=c:DriveEffect(-9,0,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.sptg,
		s.spop,
		nil,nil,nil,
		s.enchk
	)
	--[[[OD]: Shuffle up to 3 "Crystarion" cards from your GY into the Deck, and if you do, draw 1 card.]]
	local d2=c:OverDriveEffect(2,CATEGORY_TODECK|CATEGORY_DRAW,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	--[[If this card is Normal or Special Summoned: You can send 1 "Crystarion Ascendant - Pillar of Cobalt" from your Deck to the GY,
	and if you do, you can send 1 "Crystarion" card from your Deck to the GY, except "Crystarion Ascendant - Pillar of Cobalt".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If a "Crystarion" Ritual Monster(s) is Ritual Summoned (except during the Damage Step): You can return this card to your hand, and if you do, you can Engage it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--D1
function s.enchk(c,ct,e,tp)
	local exc=nil
	if c:IsEnergy(ct) and c:DestinationRedirect(LOCATION_GRAVE,REASON_RULE)~=LOCATION_GRAVE then
		exc=c
	end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,exc,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_CRYSTARION_ASCENDANT_PILLAR_OF_COBALT) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		if not tc:IsFaceup() then return end
		local eid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetLabel(eid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.indcon)
		e1:SetTarget(s.indtg)
		e1:SetValue(aux.indoval)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.indcon(e)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.indtg(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION)
end

--D2
function s.tdfilter(c)
	return c:IsSetCard(ARCHE_CRYSTARION) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.ShuffleIntoDeck(g,tp)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--E1
function s.tgfilter(c)
	return c:IsCode(CARD_CRYSTARION_ASCENDANT_PILLAR_OF_COBALT) and c:IsAbleToGrave()
end
function s.tgfilter2(c)
	return c:IsSetCard(ARCHE_CRYSTARION) and not c:IsCode(CARD_CRYSTARION_ASCENDANT_PILLAR_OF_COBALT) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if tg and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsLocation(LOCATION_GRAVE) then
		local mg=Duel.Group(s.tgfilter2,tp,LOCATION_DECK,0,nil)
		if #mg>0 and Duel.SelectYesNo(tp,STRING_ASK_SEND_TO_GY) then
			Duel.HintMessage(tp,HINTMSG_TOGRAVE)
			local sg=mg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SearchAndEngage(c,e,tp)
	end
end