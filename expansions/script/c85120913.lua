--[[
Reawakening of the Primordial Sun
Risveglio del Sole Primordiale
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN)
	c:Activation(true,true)
	--This card's name is also treated as "Macro Cosmos" while on the field.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetValue(CARD_MACRO_COSMOS)
	c:RegisterEffect(e0)
	--"Helios - The Primordial Sun(s)" you control are unaffected by your opponent's card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_HELIOS_THE_PRIMORDIAL_SUN))
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--[[Once per turn: You can activate 1 of these effects.
	● Special Summon 1 "Helios - The Primordial Sun" from your Deck or banishment.
	● If you control "Helios - The Primordial Sun": Set 1 Spell/Trap that mentions "Helios - The Primordial Sun" or "Macro Cosmos" directly from your Deck. It can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

--E1
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--E2
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sfilter(c,ft)
	return c:Mentions(CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_MACRO_COSMOS) and (not ft or (c:IsType(TYPE_FIELD) or ft>0)) and c:IsSSetable()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsType(TYPE_FIELD) and not c:IsInBackrow() then
		ft=ft-1
	end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_HELIOS_THE_PRIMORDIAL_SUN),tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,ft)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	e:SetCategory(0)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	if opt==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSetAndFastActivation(tp,g,e)
		end
	end
end