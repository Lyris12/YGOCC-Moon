--[[
Lich-Lord's Sleepless Slumber
Sonno Insonne del Signore-Lich
Card Author: Walrus
Scripted by: XGlitchy30
]]
local s,id,o=GetID()
function s.initial_effect(c)
	--[[Target 1 DARK "Number" Xyz Monster you control and 2 Zombie monsters in your GY; attach those targets in the GY to the first target as material.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except during the turn it was sent there: You can banish this card and discard 1 "Lich-Lord" card;
	Special Summon 1 "Lich-Lord" monster from your Deck or banishment, but shuffle it into the Deck when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(aux.exccon,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_NUMBER) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.filter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsCanOverlay(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExists(true,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,2,nil,tp) end
	local g1=Duel.Select(HINTMSG_FACEUP,true,tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:GetFirst():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	local g2=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_GRAVE,0,2,2,g1,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,#g2,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g<2 then return end
	local xyz=g:Filter(Card.HasFlagEffect,nil,id):GetFirst()
	if xyz and s.xyzfilter(xyz) and xyz:IsControler(tp) then
		g=g:Filter(s.filter,xyz,tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		if #g>0 then
			Duel.Attach(g,xyz)
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if sc then
		Duel.SendtoGrave(sc,REASON_COST|REASON_DISCARD)
	end
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_LICH_LORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummonRedirect(e,g,0,tp,tp,false,false,POS_FACEUP,false,LOCATION_DECKSHF)
	end
end