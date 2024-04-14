--[[
Birth of the Sun
Nascita del Sole
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS)
	--[[Activate 1 of the following effects.
	● If you control no monsters: Add 1 card that mentions "Helios - The Primordial Sun" from your Deck to your hand, also, for the rest of this turn,
	you cannot Special Summon monsters, except LIGHT Pyro monsters.
	● If you control "Helios - The Primordial Sun": Add 1 card that mentions "Macro Cosmos" from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--If "Macro Cosmos(s)" you control would be destroyed while you control "Helios - The Primordial Sun" or "Helios Duo Megistus", you can return this banished card to the GY instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c,code)
	return c:Mentions(code) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil,CARD_HELIOS_THE_PRIMORDIAL_SUN)
	local b2=Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_HELIOS_THE_PRIMORDIAL_SUN),tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil,CARD_MACRO_COSMOS)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	local code=opt==0 and CARD_HELIOS_THE_PRIMORDIAL_SUN or CARD_MACRO_COSMOS
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,code)
	if #g>0 then
		Duel.Search(g,tp)
	end
	if opt==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(3,id)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.limit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.limit(e,c,sp,st,spos,tp,se)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PYRO))
end

--E2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_MACRO_COSMOS) and c:IsOnField() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS),tp,LOCATION_ONFIELD,0,1,nil)
			and eg:IsExists(s.repfilter,1,nil,tp)
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT|REASON_RETURN|REASON_REPLACE)
end