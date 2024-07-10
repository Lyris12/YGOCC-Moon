--[[
Automatyrant Static Energy Cannon
Automatiranno Cannone Statico a Energia
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is sent to the GY: You can Special Summon 1 "Automatyrant" monster from your hand, except "Automatyrant Static Energy Cannon".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[Once per turn, you can either: Target 1 face-up Machine monster you control; equip this card to that target,
	OR: Unequip this card and Special Summon it. If the equipped monster would be destroyed by battle or card effect, destroy this card instead.]]
	aux.EnableUnionAttribute(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
	--[[Once per turn: You can send the top 3 cards of your Deck to the GY; destroy 1 card your opponent controls, and if you do, it cannot activate its effects until the end of this turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetFunctions(aux.IsEquippedCond,s.descost,s.destg,s.desop)
	c:RegisterEffect(e3)
	--[[If the equipped monster destroys an opponent's monster by battle: Inflict 500 damage to your opponent for each card equipped to the equipped monster.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetFunctions(s.damcon,nil,s.damtg,s.damop)
	c:RegisterEffect(e4)
end
--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,Card.IsPreviousLocation),1,nil,LOCATION_DECK)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E3
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.Destroy(g,REASON_EFFECT)>0 and aux.BecauseOfThisEffect(e)(tc) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(STRING_CANNOT_TRIGGER)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end

--E4
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec) and ec:IsRelateToBattle() and ec:IsStatus(STATUS_OPPO_BATTLE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local ct=e:GetHandler():GetEquipTarget():GetEquipGroup():GetCount()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local ct=ec:GetEquipGroup():GetCount()
	if ct>0 then
		Duel.Damage(p,ct*500,REASON_EFFECT)
	end
end