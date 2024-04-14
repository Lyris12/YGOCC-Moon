--[[
Primordial Cubicle
Cubicolo Primordiale
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS,CARD_HELIOS_TRICE_MEGISTUS)
	--[[When this card is activated: You can add 1 LIGHT Pyro monster from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If you Normal or Special Summon "Helios - The Primordial Sun(s)" (except during the Damage Step): You can activate 1 of the following effects, depending on whose turn it is.
	● Your turn: Add 1 "Helios Duo Megistus" or "Helios Trice Megistus" from your Deck to your hand, then you can destroy 1 card your opponent controls.
	● Opponent's Turn: Set 1 Spell/Trap that mentions "Helios - The Primordial Sun" directly from your Deck. It can be activated this turn.]]
	local chk=aux.AddThisCardInSZoneAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetLabelObject(chk)
	e2:SetFunctions(s.econ,nil,s.etg,s.eop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
end
--E1
function s.filter(c,e,tp)
	return c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_PYRO) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp)
	if Duel.PlayerHasFlagEffect(tp,id) then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.HintMessage(tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.Search(sg,tp)
	end
end

--E2
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN) and c:IsSummonPlayer(tp)
end
function s.econ(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.thfilter(c)
	return c:IsCode(CARD_HELIOS_DUO_MEGISTUS,CARD_HELIOS_TRICE_MEGISTUS) and c:IsAbleToHand()
end
function s.setfilter(c)
	return c:IsST() and c:Mentions(CARD_HELIOS_THE_PRIMORDIAL_SUN) and c:IsSSetable()
end
function s.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	local p=Duel.GetTurnPlayer()
	if chk==0 then
		if p==tp then
			return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
		elseif p==1-tp then
			return Duel.IsExists(false,s.setfilter,tp,LOCATION_DECK,0,1,nil)
		end
		return false
	end
	e:SetCategory(0)
	if p==tp then
		Duel.SetTargetParam(0)
		e:SetCategory(CATEGORIES_SEARCH|CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	elseif p==1-tp then
		Duel.SetTargetParam(1)
	end
end
function s.eop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetParam()
	if not p then return end
	if p==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SearchAndCheck(g,tp) then
			local dg=Duel.Group(nil,tp,0,LOCATION_ONFIELD,nil)
			if #dg>0 and Duel.SelectYesNo(tp,STRING_ASK_DESTROY) then
				Duel.ShuffleHand(tp)
				Duel.HintMessage(tp,HINTMSG_DESTROY)
				local sg=dg:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
		end
	
	elseif p==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSetAndFastActivation(tp,g,e)
		end
	end
end