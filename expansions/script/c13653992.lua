--Principalitum, Creatore Ængelico || Principalitum, Ængelic Creator
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,11,s.TLcon,aux.FilterBoolFunction(Card.IsSetCard,0xae6),s.TLop)
	--base stats
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_SINGLE)
	e01:SetCode(EFFECT_SET_BASE_ATTACK)
	e01:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e01:SetRange(LOCATION_MZONE)
	e01:SetValue(s.atkval)
	c:RegisterEffect(e01)
	local e02=e01:Clone()
	e02:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e02)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--actlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--atk change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
--timeleap summon
function s.excfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xae6)
end
function s.TLcon(e,c)
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)>=10
		and not g:IsExists(s.excfilter,1,nil)
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c,g)
	Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
--base stats
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
--ss
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TIMELEAP) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,tp)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
--actlimit
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
--atk change
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.cfilter(c)
	return c:IsSetCard(0xae6) and c:IsAbleToRemoveAsCost(c,POS_FACEDOWN)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ag=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,e:GetHandler())
	local atk=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)*100
	if chk==0 then
		return #ag>0
	end
	if #ag>0 and atk>0 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,ag,#ag,tp,ev+atk)
	end
end
function s.afilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xae6) and c:IsFaceup()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,e:GetHandler())
	local atk=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)*100
	if #ag>0 then
		for tc in aux.Next(ag) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(ev+atk)
			tc:RegisterEffect(e1)
		end
	end
end