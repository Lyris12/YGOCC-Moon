--created & coded by Lyris, art by httydquackson.fl of Instagram
--European Voice Accent Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigAccentType(c)
	aux.AddAccentProc(c,"FunRep",aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),2,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAIN_ACTIVATED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10)
	e2:SetCondition(s.chcon)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local g=c:GetMaterial()
	if not g then return false end
	for tc in aux.Next(g) do
		if re:GetHandler():IsCode(tc:GetCode()) then return false end
	end
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler():IsLocation(LOCATION_REMOVED)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLevelAbove(5)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeTargetCard(ev,Group.CreateGroup())
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(math.max(c:GetAttack(),c:GetDefense()))
	e1:SetValue(s.damval)
	Duel.RegisterEffect(e1,tp)
end
function s.damval(e,re,val,r,rp,rc)
	local l=e:GetLabel()
	if val<=l then return 0 else return val end
end
