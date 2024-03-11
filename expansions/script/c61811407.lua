--[[
Dread Bastille - Concerto
Bastiglia dell'Angoscia - Concerto
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_DREAD_BASTILLE),8,3,nil,nil,99)
	--This card's original DEF is equal to the number of materials attached to it x 1500.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SET_BASE_DEFENSE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.defval)
	c:RegisterEffect(e0)
	--If this card is Xyz Summoned: You can attach 1 of your "Dread Bastille" cards that is banished or in your GY to this card as material.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.attg,s.atop)
	c:RegisterEffect(e1)
	--(Quick Effect): You can detach 1 material from this card; Special Summon 1 Level 8 Rock monster from your Deck in Defense Position.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.DetachSelfCost(),s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[If this face-up Xyz Summoned card you control is sent to the GY: You can gain LP equal to the DEF it had while face-up on the field, and if you do, draw 1 card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_RECOVER|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
end
--E0
function s.defval(e,c)
	return c:GetOverlayCount()*1500
end

--E1
function s.atfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsCanOverlay(tp)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExists(false,s.atfilter,tp,LOCATION_GB,0,1,nil,tp)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
		local g=Duel.Select(HINTMSG_ATTACH,false,tp,aux.Necro(s.atfilter),tp,LOCATION_GB,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and not tc:IsImmuneToEffect(e) then
			Duel.HintSelection(g)
			Duel.Attach(tc,c)
		end
	end
end

--E2
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local val=c:GetPreviousDefenseOnField()
	if chk==0 then return val>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetTargetParam()
	if val and Duel.Recover(tp,val,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end