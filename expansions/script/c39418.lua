--Dracosis Kelathym
--Dracosi Kelathym
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2,s.alt,aux.Stringid(id,0))
	--[[When this card is Xyz Summoned: You can shuffle up to 5 "Dracosis" cards from your GY into your Deck (min. 2); draw 1 card and reveal it,
	then this monster gains 1 of these effects depending on the type of that card (Monster, Spell, Trap)
	● Monster: This card gains 500 ATK/DEF.
	● Spell: This card is unaffected by your opponent's Spell/Trap effects.
	● Trap: Once per turn, this card cannot be destroyed by battle or card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.XyzSummonedCond)
	e1:SetCost(aux.ToDeckCost(aux.ArchetypeFilter(0x300),LOCATION_GRAVE,0,2,5))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsSetCard(0x300)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRace)==#g or g:GetClassCount(Card.GetAttribute)==#g
end
function s.alt(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,6) and c:IsSetCard(0x300)
end

function s.filter1(c)
	return c:IsSetCard(0x300) and c:IsAbleToDeckAsCost()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)<=0 then return end
	local g=Duel.GetOperatedGroup()
	local tc=g:GetFirst()
	if not tc:IsControler(tp) or not tc:IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,tc)
	local typ=tc:GetType()
	local opt=aux.Option(tp,id,1,typ&TYPE_MONSTER>0,typ&TYPE_SPELL>0,typ&TYPE_TRAP>0)
	if not opt or opt<0 or opt>2 then return end
	local c=e:GetHandler()
	Duel.BreakEffect()
	if opt==0 then
		c:UpdateATKDEF(500,500,true,c)
	elseif opt==1 then
		local e1=Effect.CreateEffect(c)
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.efilter)
		e1:SetOwnerPlayer(tp)
		c:RegisterEffect(e1)
	elseif opt==2 then
		local e1=Effect.CreateEffect(c)
		e1:Desc(3)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL|TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function s.valcon(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end