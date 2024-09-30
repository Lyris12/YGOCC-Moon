--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Champion of The Primordial Sun - Solaire
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_DUO_MEGISTUS)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,s.mfilter,6,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	aux.EnableChangeCode(c,CARD_HELIOS_DUO_MEGISTUS)
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:OPT()
	e4:SetRelevantTimings()
	e4:SetCost(aux.DetachSelfCost())
	e4:SetTarget(aux.DummyCost)
	e4:SetOperation(s.limop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:Desc(2)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_RELEASE)
	e5:HOPT()
	e5:SetCondition(s.rmcon)
	e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
end
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PYRO)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*400
end
function s.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_COST)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(1,id)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.alimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.alimit(e,re,tp)
	return re:GetActivateLocation()&LOCATION_REMOVED>0
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_MACRO_COSMOS)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=not e:IsCostChecked() and e:GetHandler() or nil
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,exc)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,PLAYER_ALL,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
