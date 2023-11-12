--[[
Crystarion Ascendant - Pillar of Diamond
Cristarione Ascendente - Pilastro di Diamante
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[While you have an Engaged "Crystarion" Drive Monster, this card cannot be targeted by your opponent's card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.imcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--If this card is Ritual Summoned: You can Set 1 "Crystarion" Spell/Trap from your Deck. It can be activated this turn.
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(aux.RitualSummonedCond,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
	--[[When a card or effect is activated that would change an Engaged Drive Monster(s)'s Energy (Quick Effect):
	You can declare 1 card name, and if you do, negate the activated effects and effects on the field of cards with that name, until the end of this turn.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
end
--E1
function s.imcon(e)
	local en=Duel.GetEngagedCard(e:GetHandlerPlayer())
	return en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION)
end

--E2
function s.setfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_CRYSTARION) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSetAndFastActivation(tp,g,e)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tabs1=Duel.GetCustomOperationInfo(ev,CATEGORY_UPDATE_ENERGY)
	local tabs2=Duel.GetCustomOperationInfo(ev,CATEGORY_CHANGE_ENERGY)
	local tabs3=Duel.GetCustomOperationInfo(ev,CATEGORY_RESET_ENERGY)
	local ct1=tabs1 and #tabs1 or 0
	local ct2=tabs2 and #tabs2 or 0
	local ct3=tabs3 and #tabs3 or 0
	return ct1+ct2+ct3>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(s.distg1)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	e2:SetLabel(ac)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.distg2)
	e3:SetLabel(ac)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.distg1(e,c)
	local ac=e:GetLabel()
	if c:IsST() then
		return c:IsCode(ac)
	else
		return c:IsCode(ac) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
function s.distg2(e,c)
	local ac=e:GetLabel()
	return c:IsCode(ac)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	return re:GetHandler():IsCode(ac)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end